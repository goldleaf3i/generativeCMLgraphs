function [ indice ] = label2index( label )

switch label
    case 'C'
        indice=1;
    case 'H'
        indice=2;
    case 'R'
        indice=3;
    case 'N'
        indice=4;
    case 'F'
        indice=5;
    case 'S'
        indice=6;
    case 'Y'
        indice=7;
    case 'M'
        indice=8;
    case 'K'
        indice=9;
    case 'B'
        indice=10;
    case 'E'
        indice=11;
        
%     case 'S'
%         indice=1;
%     case 'M'
%         indice=2;
%     case 'B'
%         indice=3;
%     case 'H'
%         indice=4;
%     case 'C'
%         indice=5;
%     case 'X'
%         indice=6;
%     case 'Y'
%         indice=7;
%     case 'Z'
%         indice=8;
%     case 'E'
%         indice=9;
%     case 'T'
%         indice=10;
%     case 'W'
%         indice=11;
%     case 'O'
%         indice=12;
%     case 'K'
%         indice=13;
end

end

