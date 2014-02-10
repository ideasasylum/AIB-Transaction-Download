require "rubygems"
require "mechanize"
require "logger"
require "csv"
require 'date'
require 'optparse'

$agent = Mechanize.new {|a| a.log = Logger.new("mech.log") }

# setup the cmd-line parser
options = {}
OptionParser.new do |opts|
  opts.banner = "This script will download your AIB transactions for all accounts into a CSV between the specified date and yesterday"
  
  opts.on('-p', '--pac PAC', "Your 5-digit Personal Access Code") do |pac|
    options[:pac] = pac.scan(/./)
  end
  
  opts.on('-n','--regnum REGNUM', 'Registration Number') do | reg|
    options[:reg] = reg
  end
  
  opts.on('-h', '--home HOME', 'Last 4 digits of your home phone number') do |h|
    options[:home] = h
  end
  
  opts.on('-w', '--work WORK', 'Last 4 digits of your work phone number') do |w|
    options[:work] = w
  end
  
  opts.on('-v', '--visa VISA', 'Last 4 digits of your primary AIB visa card') do |v|
    options[:visa] = v
  end
  
  opts.on('-d', '--date DATE', 'The start date of the transactions dd/mm/yyyy format') do |d|
    pp d
    options[:date] = Date.strptime(d, '%d/%m/%Y')
  end
  
  opts.on_tail("--help", "Show this message") do
    puts opts
    exit
  end
  
end.parse!
  

def login(regnum, pac, home, work, visa)
    ########### Login Page 1
    puts "###################################### Step 1"
    $agent.get("https://aibinternetbanking.aib.ie/inet/roi/login.htm") do |page|

        page2 = page.form('form1') do |form|
            form.regNumber = regnum
        end.submit
        
        
        ############ Login Page 2
        puts "###################################### Step 2"
        page3 = page2.form('loginstep2') do |pac_form|
            i=1
            # PAC code
            digits = page2.search("//input[contains(@id, 'digit')]/../label/strong/text()")
            digits.each{ |d| 
                pac_index = d.text.match(/Digit ([12345])/)[1].to_i
                pac_form["pacDetails.pacDigit#{i}"] = pac[pac_index-1]
                #puts "#{i}: Digit #{pac_index} => #{PAC[pac_index-1]}"
                i+=1
            }
            
            # Challenge: Visa, Work or Home phone
            challenge = page2.search("//label[@for='challenge']/strong[2]/.").text()
            if challenge.index('Visa') 
                code = visa
            elsif challenge.index('work')
                code = work
            elsif challenge.index('home')
                code = home
            end
            pac_form['challengeDetails.challengeEntered'] = code
            #puts "#{challenge} = #{code}"
        end.submit
    end
end

def update_transactions(from, to)
    ############# Navigate to transaction search page
    puts "###################################### Step 3"
    if $agent.current_page.search("//h1/.").text() == 'You are securely logged in.'
        puts "#################################### Success logging in!"
        statements = $agent.current_page.form_with(:action => 'statement.htm').submit
        numAccounts = statements.search("//select[@id='index']/option").length
        statements.form_with(:action => 'searchtransactions.htm').submit
        
        for account in 1..numAccounts
            statementSearch = $agent.current_page
            # get the account name
            account_name = statementSearch.search("//select[@id='dsAccountListIndex']/option[#{account+1}]").text()
            puts account_name
            # fill out the transaction search form
            results = statementSearch.form_with(:action => 'searchtransactions.htm') do |statementForm|
                 statementForm.startDateDD = from.strftime('%d')
                 statementForm.startDateMM = from.strftime('%m')
                 statementForm.startDateYYYY = from.strftime('%Y')
                 statementForm.endDateDD = to.strftime('%d')
                 statementForm.endDateMM = to.strftime('%m')
                 statementForm.endDateYYYY = to.strftime('%Y')
                 statementForm.field_with(:name => 'dsAccountListIndex').options[account].select
                 pp statementForm
            end.submit

             # grab the transactions table
             transactions = []
             for row in results.search("//table//th[text()='Date:']/../../../tbody/tr")
                date = row.search('td[1]').text
                desc = row.search('td[2]').text
                debit = row.search('td[3]').text
                credit = row.search('td[4]').text
                balance = row.search('td[5]').text
                puts "#{date} #{desc} #{debit} #{credit} #{balance}"
                transactions << [date, desc, debit, credit, balance] unless (debit.length == 0 and credit.length == 0)
             end
             pp transactions
             
             CSV.open("#{account_name}_#{from.to_s}-#{to.to_s}.csv", "w") do |csv|
                csv << ["Date", "Description", "Debit", "Credit", "Balance"]
                transactions.each { |t| csv << t }
             end
        end
    end
     
end

pp options
to_date = Date.today-1
login options[:reg], options[:pac], options[:home], options[:work], options[:visa]
update_transactions options[:date], to_date


