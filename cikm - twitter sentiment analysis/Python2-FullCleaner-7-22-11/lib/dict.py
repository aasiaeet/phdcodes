from lib import dawg
import csv

class WordList:
    def __contains__(self, word):
        """Enables the in operator"""
        return word in self.words
    
    def __init__(self,wlist):
        self.words = wlist

class FileWordList(WordList):    
    def __del__(self):
        self.close()
    
    def limit_contents(self):
        while len(self.contentsCache)> self.contentsLimit:
            self.contentsCache = self.contentsCache[1:]
    
    def __contains__(self, word):
        """Enables the in operator"""
        if word in self.contentsCache:
            return True
        for line in self.file:
            fileComp = line.rstrip()
            fileComp = fileComp.lstrip()
            wordComp = word.lstrip()
            wordComp = wordComp.rstrip()
            if fileComp.lower() == wordComp.lower():
                if not(line in self.contentsCache):
                    self.contentsCache.append(line.lower())
                self.file.seek(0)
                return True
        self.file.seek(0)
        self.limit_contents()
        return False
    
    def __init__(self, wordFile, contents_limit=500):
        self.file = None
        if isinstance(wordFile,str):
            self.file = open(wordFile,"r")
        else:
            self.file = wordFile
        self.contentsCache = []
        self.contentsLimit = contents_limit
        
    def close(self):
        """Close the FileWordList file"""
        if self.file:
            self.file.close()

class DAWGWordList(WordList):
    def __init__(self,words):
        self.dawg = dawg.Dawg()
        if isinstance(words,str):
            file = open(words,"r")
            wordsList = file.read().split()
            #Remove this if the file has been cleaned!
            for i in range(len(wordsList)):
                newword = wordsList[i]
                newword = newword.lstrip("\r\n\"")
                newword = newword.rstrip("\r\n\"")
                wordsList[i] = newword
            for word in wordsList:
                if word:
                    self.dawg.insert(word)
            del wordsList
        else:
            for word in words:
                self.dawg.insert(word)
        self.dawg.finish()
    
    def __contains__(self,word):
        return bool(self.dawg.lookup(word))

class ReplacementDict(WordList):
    def __init__(self,rdict):
        self.dict = rdict
        
    def __contains__(self,word):
        return word in self.dict
        
    def get_replacement(self,word):
        if word in self:
            return self.dict[word]
        else:
            return False
            
class CSVReplacementDict(ReplacementDict):
    def __init__(self,wordFile):
        self.file = None
        if isinstance(wordFile,str):
            self.file = open(wordFile,"r")
        else:
            self.file = wordFile
        self.reader = csv.reader(self.file)
        self.contentsCache = {}
    
    def __contains__(self,word):
        if word.lower() in self.contentsCache:
            return True
        for line in self.reader:
            workingLine = line[0].lower()
            if workingLine == word.lower():
                self.contentsCache[workingLine] = line[1].lower()
                self.file.seek(0)
                return True
        self.file.seek(0)
        return False
        
    def get_replacement(self,word):
        workingWord = word.lower()
        if workingWord in self.contentsCache:
            return self.contentsCache[workingWord]
        for line in self.reader:
            workingComp = line[0].lower()
            workingValue = line[1].lower()
            if workingWord == workingComp:
                self.contentsCache[workingWord] = workingValue
                self.file.seek(0)
                return workingValue
        self.file.seek(0)
        return False