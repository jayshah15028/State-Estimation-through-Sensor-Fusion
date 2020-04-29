function [ indx ] = residual( wn )
l = length(wn);

Ns = floor(l .* wn);
% The "remainder" or "residual" count:
R = sum( Ns );
% The number of particles which will be drawn stocastically:
l_res = l-R;
% The modified weights:
Wm = (l .* wn - floor(l .* wn))/l_res;
% Draw the deterministic part:
% ---------------------------------------------------
i=1;
for j=1:l,
    for k=1:Ns(j),
        indx(i)=j;
        i = i +1;
    end
end;
% And now draw the stocastic (Multinomial) part:
% ---------------------------------------------------
Q = cumsum(Wm);

while (i<=l),
    sampl = rand(1,1);  % (0,1]
    j=1;
    while (Q(j)<sampl),
        j=j+1;
    end;
    indx(i)=j;
    i=i+1;
end

