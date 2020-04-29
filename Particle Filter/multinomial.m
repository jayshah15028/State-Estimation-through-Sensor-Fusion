function [index]=multinomial(wn)
M=length(wn);
for i=1:M
    index(i)=find(rand <= cumsum(wn),1);
end