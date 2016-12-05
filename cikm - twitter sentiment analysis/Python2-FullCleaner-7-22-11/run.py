from lib import tweet as t
from lib import dict
from lib import spell
from lib import repetition
from numpy import *
import codecs
import os
import csv
import pickle
from xml.sax.saxutils import unescape
import gc

DATA_COL_NUM = 5
ID_COL_NUM = 0
EMOTION_COL_NUM = 2
CONFIDENCE_COL_NUM = 3
CONFIDENCE_SUMMARY_COL_NUM = 4
TWEET_SLICES = 200

def conditional_print(string,boolval):
    if boolval:
        print string

class Cleaner:
    def __init__(self,stem = True,stopWordsList = None,englishList = None,replacementDict = None,debug = False,emoticons = [],twitterWords = []):
        self.stem = stem
        self.twitterWords = twitterWords
        self.emoticons = emoticons
        if stopWordsList is None:
            self.stopWords = dict.WordList([])
        else:
            self.stopWords = stopWordsList
        if englishList is None:
            self.englishList = None
        else:
            self.englishList = englishList
        if replacementDict is None:
            self.replacementDict = dict.ReplacementDict({})
        else:
            if isinstance(replacementDict,dict.ReplacementDict):
                self.replacementDict = replacementDict
            else:
                self.replacementDict = dict.ReplacementDict(replacementDict)
            
        #Create needed objects
        if not(englishList is None):
            self.spellCorrector = spell.Corrector(self.englishList)
        else:
            self.spellCorrector = None
        self.debug = debug
    
    def clean(self,tweet):
        originalTweetSave = str(tweet)
        """Main function that actually handles the cleaning process
        
        tweet -- the tweet.Tweet object to clean
        """
        
        originalTweetSave = str(tweet)
        debug = self.debug #Keep this line!
        conditional_print("Cleaning: "+str(tweet),debug)
        
        def negate(function):
            #Function decorator to negate the return value of a function
            def negated(*args,**kwargs):
                return not function(*args,**kwargs)
            return negated
        
        #Prep: Unescape XML
        conditional_print("Step: 0",debug)
        tweet.apply_to_all((lambda string: unescape(string,{"&quot;":'"'})))
        
        #Step 1: Lower Case
        conditional_print("Step: 1",debug)
        tweet.apply_to_all((lambda string: string.lower()))
        
        #Step 2: Remove Hyperlinks
        conditional_print("Step: 2",debug)
        def is_hyperlink(string):
            starts = ["http://","https://","www.","{link}"]
            ends = [".com",".edu",".us",".org"]
            #Returns True if string represents a hyperlink
            for start in starts:
                if string.startswith(start):
                    return True
            for end in ends:
                if string.endswith(end):
                    return True
            return False
        tweet.filter(negate(is_hyperlink))
        
        #TODO: FINISH THIS STEP, IT HANDLES HASHTAGS
        conditional_print("Step: 2.5 (Hashtags)",debug)
        def is_hashtag(string):
            if string.startswith("#"):
                return True
            return False
        def flag_hashtags(string):
            if is_hashtag(string):
                string.hashtag = True
            else:
                string.hashtag = False
            return string
        tweet.apply_to_all(flag_hashtags)
        
        #Step 2: Remove @mentions
        conditional_print("Step: 2",debug)
        tweet.filter(negate((lambda string: string.startswith("@"))))
        #extra: remove any empty strings
        tweet.filter(bool)
        
        #Step 3: Remove Special Characters
        conditional_print("Step: 3",debug)
        def remove_special_chars(string):
            if str(string) in self.emoticons or str(string) in self.twitterWords:
                return string
            newString = t.Word("")
            for char in string:
                if char.isalnum():
                    newString+=char
            return newString
        tweet.apply_to_all(remove_special_chars)
        #extra: remove any empty strings
        tweet.filter(bool)
        
        #Step 4: Remove Stop Words
        conditional_print("Step: 4",debug)
        tweet.filter(negate((lambda string: str(string) in self.stopWords)))
        
        #Step 5: Remove Repetitions
        conditional_print("Step: 5",debug)
        tweet.apply_to_all(repetition.eliminateRepeatedCharacters)
        
        #Step 6: Apply Replacements
        conditional_print("Step: 6",debug)
        def replace_word(string):
            if string in self.replacementDict:
                return replacementDict.get_replacement(string)
            return string
        tweet.apply_to_all(replace_word)
        
        #Step 7: Spell Checking
        conditional_print("Step: 7",debug)
        def check_spelling(string):
            if str(string) in self.twitterWords:
                return string
            if self.spellCorrector is None:
                return string
            if string.isnumeric():
                return string
            return self.spellCorrector.correct(string)
        tweet.apply_to_all(check_spelling)
        
        if self.stem:
            #Step 8: Porter Stem All Words
            conditional_print("Step: 8",debug)
            tweet.apply_to_all((lambda word: word.porterstem()))
            
        tweet.original = originalTweetSave
        return tweet

if __name__ == "__main__":
    #Numpy stuff here
    words = []
    tweets = []
    matrix = None
    try:
        datafiles = []
        stopWordsDict = []
        replacementDict = {}
        englishDict = None
        emoticons = []
        tweetDict = []
        try:
            tweetDict = dict.FileWordList(open("tweetdic.txt","r"))
            print(str("b/c" in tweetDict))
        except Exception:
            tweetDict = []
        try:
            emoticons = dict.FileWordList(open("emoticons.txt","r"))
        except Exception:
            emoticons = []
        try:
            stopWordsDict = dict.DAWGWordList("stopwords.txt") #Open stopwords list
        except Exception:
            stopWordsDict = [] #Probably no such file
            raise
        try:
            replacementDict = dict.CSVReplacementDict(open("replacements.csv","r"))
        except Exception:
            replacementDict = dict.ReplacementDict({})
        try:
            englishDict = open("words.txt","r")
        except Exception:
            englishDict = None
        
        #Create Cleaner object
        cleaner = Cleaner(stem = False,stopWordsList=stopWordsDict,englishList = englishDict,replacementDict = replacementDict,emoticons = emoticons,twitterWords = tweetDict)
        
        for fileName in os.listdir(os.getcwd()):
            #Load datafiles starting with "data"
            if fileName.lower().startswith("data"):
                datafiles.append(fileName)
                print("Added data file: "+fileName+".")
        fileCount = 0
        for fileName in datafiles:
            fileCount += 1
            with codecs.open(fileName,"r",encoding="utf-8") as infile:
                #Compute new file names
                newfileName = fileName.split(".")
                newfileName[0] += "_clean"
                newfileName = ".".join(newfileName)
                with codecs.open(newfileName,"ab",encoding="utf-8") as outfile:
                    #Actually clean the data
                    reader = csv.reader(infile)
                    writer = csv.writer(outfile)
                    rownum = 0
                    for row in reader:
                        if rownum<=0:
                            #Skip the first row of titles
                            writer.writerow(row)
                            rownum += 1
                            continue
                        cleanText = ""
                        print("Cleaning row: "+str(rownum)+" in file "+str(fileCount)+".")
                        try:
                            def get_emotion_from_string(string):
                                workingString = string.lstrip("\n\"'")
                                emotesobj = t.Emotions()
                                for val in emotesobj:
                                    if workingString.lower().startswith(val.lower()):
                                        return emotesobj.get_value(val)
                                return None
                            #Actual cleaning operation
                            id = str(row[ID_COL_NUM])
                            emote = get_emotion_from_string(row[EMOTION_COL_NUM])
                            confidence = float(row[CONFIDENCE_COL_NUM])
                            confidenceSum = {}
                            for item in row[CONFIDENCE_SUMMARY_COL_NUM].split("\n"):
                                if not(item.isspace() or (len(item)<=0)):
                                    confidenceSum[get_emotion_from_string(item)] = float(item.split(":")[-1])
                            #Compute emotion
                            tweet = t.Tweet(row[DATA_COL_NUM],id=id,emotion=emote,confidence=confidence,emotions = confidenceSum)
                            cleanText = cleaner.clean(tweet)
                            tweets.append(cleanText)
                        except Exception:
                            print("ERROR CLEANING TWEET!")
                            raise
                        newRow = row
                        newRow[DATA_COL_NUM] = cleanText
                        writer.writerow(newRow)
                        rownum += 1
        
        #Cleanup procedure
        try:
            del datafiles
            del stopWordsDict
            del replacementDict
            del englishDict
            del cleaner
            gc.collect()
        except Exception:
            print("Error in cleanup procedure!")
        
        print("Building matrix...")
        for tweet in tweets:
            for word in tweet:
                if not(word in words):
                    words.append(word)
        matrix = None
        sumVectors=[]
        sliceCount = 0
        while True:
            try:
                matrix = zeros(shape=(TWEET_SLICES,len(words)))
            except Exception:
                matrix = None
                print("ERROR CREATING MATRIX!")
            #Count words into array
            if not(matrix is None):
                for i in range(TWEET_SLICES):
                    if not(i+(TWEET_SLICES*sliceCount)>=len(tweets)):
                        matrix[i] = tweets[i+TWEET_SLICES*sliceCount].count_words_in_list(words)
            if TWEET_SLICES*sliceCount >= len(tweets):
                print "Matrix built!"
                break
            if not(matrix is None):
                sVector = sum(matrix,axis=0)
                sumVectors.append(sVector)
            sliceCount+=1
        tempMat = zeros(shape = (len(sumVectors),len(words)) )
        for i in range(len(sumVectors)):
            tempMat[i] = sumVectors[i]
        finalMat = sum(tempMat,axis=0)
        matFile = open("tweet_matrix.pickle","wb")
        print "Dumping matrix to file: "+matFile.name
        dictMap = {"tweets":tweets,"words":words,"sumVectors":sumVectors,"finalVector":finalMat}
        pickle.dump(dictMap,matFile)
        print "Data pickled!" 
        
        print "Starting data export!"
        print "Exporting matrix!"
        with open("matrix_export.txt","a",newline="\r\n") as outfile:
            for i in range(len(tweets)):
                tempRow = tweets[i].count_words_in_list(words)
                for ind in range(len(tempRow)):
                    if not(tempRow[ind]==0):
                        outfile.write(str(i+1)+" "+str(ind)+" "+str(tempRow[ind])+"\n")
            outfile.flush()
        print "Exporting words!"
        with open("matrix_export_words.txt","a",newline="\r\n") as outfile:
            for val in words:
                outfile.write(val+"\n")
            outfile.flush()
        print "Exporting tweets!"
        with open("matrix_export_tweet_list.txt","a",newline="\r\n") as outfile:
            for tweet in tweets:
                outfile.write(tweet.id + " "+ str(tweet)+"\n")
            outfile.flush()
            
    except Exception as e:
        print e
        raise
    #finally:
    #    input("ENTER TO EXIT")
