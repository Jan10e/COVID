import pandas as pd 
import numpy as np 
import numpy.linalg as la 
import matplotlib.pyplot as plt 

def data_prep(field):
    mainflename = "http://covidtracking.com/api/states/daily.csv"
    globdf = pd.read_csv(mainflename).fillna(0)

    rmlst = ['MP','PR','GU','VI'] # remove minor territories  
    globdf = globdf[~globdf['state'].isin(rmlst)]
    globdf['date'] = pd.to_datetime(globdf['date'],format='%Y%m%d')
    reldf = pd.pivot_table(globdf,values=field,index='date',columns='state').fillna(0.)

    return reldf 

def pca_compute_graph(reldf,field,case_threshold=100,days=10):
    ''' 
    align state time series to first day with more than 100 cases, 
    then do a PCA
    '''
    tmpcols = [] 
    
    for col in reldf.columns: 
        tmpcols.append(reldf[reldf[col] > case_threshold][col].values)

    alignpca = pd.DataFrame(tmpcols).T  
    alignpca.columns = reldf.columns
            
    pcdf = alignpca.head(days).dropna(how='any',axis=1)   

    covmat = np.cov(pcdf.T)
    lam, v = la.eig(covmat)

    v1 = v[:,0]
    v2 = v[:,1]
    v3 = v[:,2]

    # Plot first 3 principal components here: 
    plt.figure()
    title_str = 'PCA Eigenvectors with at least ' + str(case_threshold) + ' ' + field + ' cases with at least ' + str(days) + ' days of data'   
    plt.plot(v1,label='Evec-1')
    plt.plot(v2,label='Evec-2')
    plt.plot(v3,label='Evec-3')
    plt.xticks(range(len(pcdf.columns)),pcdf.columns,rotation=90)
    plt.title(title_str)
    plt.legend()
    plt.show()

if __name__ == "__main__": 
    # Align all individual states on case_threshold cases   
    
    field = 'positive'  # fields: positive, negative, hospitalized, death, ratio
    reldf = data_prep(field)
    case_threshold = 100
    days = 20 

    evecs = pca_compute_graph(reldf,field,case_threshold=case_threshold,days=days)
