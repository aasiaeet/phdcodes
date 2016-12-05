from lib import porterstem
from numpy import *
import types

class Emotions(object):
    def __iter__(self):
        for val in self.valDict:
            yield val
    
    def __init__(self):
        self.valDict = {"UNCLEAR":"unclear","NEUTRAL":"neutral",\
            "POSITIVE":"positive","NEGATIVE":"negative","UNRELATED":"unrelated","DEFAULT":"default"}
        for atr in self.valDict:
            self.__setattr__(atr,self.valDict[atr])
            
    def get_emotions(self):
        listvals = []
        for val in self.valDict.keys():
            list.append(val)
        return listvals
    
    def get_value(self,key):
        if key in self.valDict:
            return self.valDict[key]
        return None

class Word(unicode):
    def __repr__(self):
        return "Word("+unicode.__repr__(self)+")"
    
    def __getitem__(self,index):
        returnval = unicode.__getitem__(self,index)
        returnval = Word(returnval)
        return returnval
    
    def __setattr__(self,attribute,value):
        self.__dict__[attribute] = value
    
    def __getattribute__(self,*args,**kwargs):
        """Overrides the usual behavior of __getattribute__
        
        If the usual attribute to return is a function it is wrapped
        so that if it returns a str object it returns a Word object
        with copies of all attributes of the current Word object.
        
        attribute -- The attribute to get
        """
        normal =  unicode.__getattribute__(self,*args,**kwargs) #Get the normal return value
        typenormal = type(normal) #Store the type of the usual return value
        if (typenormal == types.MethodType or typenormal == types.BuiltinFunctionType
                or typenormal == types.BuiltinMethodType or typenormal == types.FunctionType
                or typenormal == types.LambdaType):#Long check for function types. Could maybe be shorter.
            #Normal return is callable
            def wrap_function(func):
                #Handles wrapping the function
                def word_function(*args,**kwargs):
                    #Makes sure that all inherited functions return Word objects
                    #Also all new Word objects copy all attributes from the original
                    returnval = func(*args,**kwargs)
                    if isinstance(returnval,str) or isinstance(returnval,unicode):
                        #Make sure we're returning a Word not a str.
                        returnval = Word(returnval)
                        #Copy attributes
                        self.copy_attributes(returnval)
                    return returnval
                #Return newly wrapped function
                return word_function
            #Final return of wrapped function
            return wrap_function(normal)
        #It's not callable, return the usual value
        return normal
    
    
    def __add__(self,other):
        returnval =  Word(unicode.__add__(self,other))
        self.copy_attributes(returnval)
        return returnval
    
    def __mul__(self,num):
        returnval = unicode.__mul__(self,num)
        returnval = Word(returnval)
        self.copy_attributes(returnval)
        return returnval
    
    def __init__(self,word):
        """Creates a Word object

        word -- The word to store in the class
        """
        self.value = word
        if isinstance(word,Word):
            word.copy_attributes(self)
        
    def porterstem(self):
        """Porter Stems the current word

        Returns a new Word object containing this word, porter stemmed.
        All other object attributes are preserved.
        """
        stemmer = porterstem.PorterStemmer()
        newWord = stemmer.stem(self,0,len(self)-1)
        return newWord
        
    def copy_attributes(self,newobject):
        dictCopy = self.__dict__.copy()
        newobjdict = newobject.__dict__.copy()
        for atr in dictCopy:
            if not(atr in newobjdict):
                newobjdict[atr] = dictCopy[atr]
        newobject.__dict__ = newobjdict

class Tweet(list):
    def __repr__(self):
        return "Tweet("+list.__repr__(self)+")"
        
    def __str__(self):
        return " ".join(self)
    
    def __init__(self,tweet,id="",emotion=None,confidence=0,emotions={}):
        """Creates a Tweet object

        tweet -- The text to use or an iterable list of Word-like objects
        """
        list.__init__(self)
        if isinstance(tweet,str):
            #Was passed a string. Make word objects
            words = tweet.split(" ")
            for word in words:
                self.append(Word(word))
        else:
            #Assume it's iterable.
            #For example a list of Word objects.
            for item in tweet:
                self.append(Word(item))
        
        self.id = id
        if emotion is None:
            self.emotion = Emotions().DEFAULT
        else:
            self.emotion = emotion
        self.confidence = confidence
        self.emotions = emotions
        
    
    def apply_to_all(self,string_func):
        """Applies the passed function to all Words in this Tweet
        
        This is done in place.
        
        string_func -- The function applied to all Words.
        """
        for i in range(len(self)):
            newval = string_func(self[i])
            if not(isinstance(newval,Word)):
                #Make sure everything's still a Word
                newval = Word(newval)
            self[i].copy_attributes(newval)
            self[i] = newval
    
    def filter(self,filter_func):
        """Includes each Word only if it satisfies filter_func
        
        If filter_func returns False for a Word, it is removed from this Tweet.
        This is done in place.
        
        filter_func -- The function used to filter
        """
        acceptedValues = []
        for element in self:
            if filter_func(element):
                acceptedValues.append(element)
        del self[:]
        for element in acceptedValues:
            self.append(element)
            
    def count_words_in_list(self,wordList):
        countVector = zeros(len(wordList))
        for i in range(len(wordList)):
            wordVal = wordList[i]
            for word in self:
                if word == wordVal:
                    countVector[i] += 1
        return countVector
            