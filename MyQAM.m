function QAM = MyQAM (m)
    if (m==0)
        QAM = complex(-1,1); 
    elseif (m==2)
        QAM = complex(-1,-1);  
    elseif (m==1)
        QAM = complex(1,1);
    elseif (m==3)
        QAM = complex(1,-1);        
    end
end