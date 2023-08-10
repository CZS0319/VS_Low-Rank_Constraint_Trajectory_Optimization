function value= soft(G,alpha)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明

value=sign(G).*max(abs(G)-alpha,0);
end