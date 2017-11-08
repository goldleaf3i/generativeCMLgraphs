function [ bit ] = ID2Bit( ID )
%converto l'id di una label in binario
maxLength = 10;
bit = de2bi(ID);
for i=1:maxLength-length(bit)
    bit = [0 bit];
end
end

