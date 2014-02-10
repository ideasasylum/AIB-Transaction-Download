**Update**: 4 years later, [AIB have finally introduced a CSV export option](http://glui.me/?i=i0btykyfi1i3156/2014-02-10_at_14.57.png/)



# README

AIB (one of the 2 main Irish banks) lives in the stone ages and doesn't provide any method of downloading your transactions in a spreadsheet-compatible format. They've recently introduced a PDF export which is designed to save them money but they show no signs of introducing something to help their customers (and, incidentally, the people who are propping up their bank). Grrr... end of the rant... here's the solution:

This script will download your AIB transactions for all accounts into a CSV between the specified date and yesterday

You will need to install the mechanize and fastercsv gems. Then invoke the script with the following options:
    -p, --pac PAC                    Your 5-digit Personal Access Code
    -n, --regnum REGNUM              Registration Number
    -h, --home HOME                  Last 4 digits of your home phone number
    -w, --work WORK                  Last 4 digits of your work phone number
    -v, --visa VISA                  Last 4 digits of your primary AIB visa card
    -d, --date DATE                  The start date of the transactions dd/mm/yyyy format
        --help                       Show this message

Example: ruby aib.rb -n 12345678 -p 12345 -h 1234 -w 1234 -v 1234 -d '01/06/2010'

Since you are trusting this script with your bank account details, I strongly suggest you read it and understand was it is doing. For your reassurance, you should remember that money cannot be moved to new account without a number from the codecard... and this script doesn't require those details. Hence, it can't transfer money out of your accounts.

After the script has executed, you will have one CSV file for each of your accounts / credit cards. From there you can import into a spreadsheet or online financial analysis service.

The script isn't particularly good at error checking and there are likely to be some edge cases where it doesn't work.
