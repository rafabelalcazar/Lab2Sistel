function QAMDemod = MyQAMDemod (m)
    if (m==complex(-1,1))
        QAMDemod = 0 ; 
    elseif (m==complex(-1,-1))
        QAMDemod = 2;  
    elseif (m==complex(1,1))
        QAMDemod = 1;
    elseif (m==complex(1,-1))
        QAMDemod = 3;        
    end
end