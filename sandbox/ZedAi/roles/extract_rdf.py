from optparse import OptionParser
from pyRdfa import processFile

def main():
    # process the command line arguments
    usage = """usage: %prog filename"""
    description = """Simple wrapper for testing documents using pyRDFa. 
    Requires pyRDfa: http://www.w3.org/2007/08/pyRdfa/#distribution"""
    
    parser = OptionParser(usage=usage, description=description)
    opts, args = parser.parse_args()
    if (len(args) == 0):
        input_file = "zed-book-profile-roles.html"
    else:
        input_file = args[0]
    
    # the simplest way to use pyRDFa
    print processFile(input_file)

if __name__ == "__main__":
    main()

