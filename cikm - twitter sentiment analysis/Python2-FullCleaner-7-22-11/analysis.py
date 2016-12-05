import cPickle
from numpy import *
from lib import tweet

PICKLE_FILE = "tweet_matrix.pickle"
PICKLE_OUT_FILE = "tweet_emotions_matrix.pickle"

def make_emotion_matrix(tweets,matrix,emotionVal):
    posIndexes = [] #List of indexes matching emotionVal
    def emotion_routine(emotionIn):
        #Find all matching emotions
        for i in len(tweets):
            if tweets[i].emotion == emotionIn:
                posIndexes.append(i)
    if isinstance(emotionVal,str):
        emotion_routine(emotionVal)
    else:
        for emotionIn in emotionVal:
            emotion_routine(emotionIn)
    posTweets = []
    posMatrix = zeros(shape = (len(posIndexes),matrix.shape[1]) )
    for i in len(posIndexes):
        posTweets.append(tweets[posIndexes[i]])
        posMatrix[i] = matrix[i]
    return posTweets,posMatrix

def make_emotion_matrix(tweets,emotionVal):
    posIndexes = []
    words = []
    for i in range(len(tweets)):
        if isinstance(emotionVal,str) or isinstance(emotionVal,int) or isinstance(emotionVal,float):
            if tweet.emotion == emotionVal:
                posIndexes.append(i)
        else:
            for em in emotionVal:
                if tweet.emotion == em:
                    posIndexes.append(i)
        
    
if __name__=="__main__":
    dataDict = cPickle.load(open(PICKLE_FILE,"rb"))
    tweets = dataDict["tweets"]
    words = dataDict["words"]
    matrix = dataDict["matrix"]
    
    emotions = tweet.Emotions()
    
    print("Building positive matrix")
    posRet = make_emotion_matrix(tweets,matrix,emotions.POSITIVE)
    print("Building negative matrix")
    negRet = make_emotion_matrix(tweets,matrix,emotions.NEGATIVE)
    print("Building neutral matrix")
    neuRet = make_emotion_matrix(tweets,matrix,[emotions.NEUTRAL,emotions.DEFAULT,emotions,UNCLEAR])
    
    outfile = open(PICKLE_OUT_FILE,"wb")
    dictMap = {"originalMatrix":matrix,"originalWords":words,"originalTweets":tweets,"positive":posRet,"negative":negRet,"neutral":neuRet}
    cPickle.dump(dictMap,outfile)