import re
from lib import tweet

# remove consecutive subsequences of repeated characters
def eliminateRepeatedCharacters(string):
    reg = re.compile(r'(.)\1{2,}')
    #reg = re.compile(r'(.)\1+')

    normalizedStr = tweet.Word(string)
    
    # all words have a default weight = 1
    weight = 1

    # remove all sequences of repeated characters
    keepLooping = True
    while keepLooping:

        out = reg.search(normalizedStr)
    
        # check if regex matched
        if out is None:
            keepLooping = False
            
        else:
            # regex matched, hence remove repeated characters
            normalizedStr = normalizedStr[:out.span()[0]+1] \
                    + normalizedStr[out.span()[1]:]
                    
            # update weight by adding the number of repetitions
            weight += out.span()[1] - out.span()[0] - 1
    try:
        normalizedStr = tweet.Word(normalizedStr)
        normalizedStr.repWeight = weight
        return normalizedStr
    except Exception:
        raise
        return normalizedStr,weight
    
if __name__ == "__main__":
    str = 'greeaaat'
    print(eliminateRepeatedCharacters(str))

    str = ':DDDDD'
    print(eliminateRepeatedCharacters(str))