#http://norvig.com/spell-correct.html
import re, collections
from lib import tweet

class Corrector:
    def __init__(self,words):
        if isinstance(words,str):
            self.file = open(words,'r')
        else:
            self.file = words
        self.NWORDS = self._train(self._words(self.file.read()))

    def _words(self,text): 
        workingWord = text.split("/")[0]
        return re.findall('[a-z]+', workingWord.lower()) 

    def _train(self,features):
        model = collections.defaultdict(lambda: 1)
        for f in features:
            model[f] += 1
        return model

    def _edits1(self,word):
       alphabet = 'abcdefghijklmnopqrstuvwxyz'
       splits     = [(word[:i], word[i:]) for i in range(len(word) + 1)]
       deletes    = [a + b[1:] for a, b in splits if b]
       transposes = [a + b[1] + b[0] + b[2:] for a, b in splits if len(b)>1]
       replaces   = [a + c + b[1:] for a, b in splits for c in alphabet if b]
       inserts    = [a + c + b     for a, b in splits for c in alphabet]
       return set(deletes + transposes + replaces + inserts)

    def _known_edits2(self,word):
        return set(e2 for e1 in self._edits1(word) for e2 in self._edits1(e1) if e2 in self.NWORDS)

    def _known(self,words): return set(w for w in words if w in self.NWORDS)

    def correct(self,inword):
        word = str(inword)
        candidates = self._known([word]) or self._known(self._edits1(word)) or self._known_edits2(word) or [word]
        returnval =  max(candidates, key=self.NWORDS.get)
        if isinstance(inword,tweet.Word):
            returnval =  tweet.Word(returnval)
            inword.copy_attributes(returnval)
        return returnval