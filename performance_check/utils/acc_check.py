

def accuracy_check(preds, labels, n_data):
    acc = 0
    for i in range(n_data):
        if preds[i] == labels[i]:
            acc+=1 
            
    print( "\nAccuracy: {:05.2f}%   ".format((acc / n_data) * 100))
