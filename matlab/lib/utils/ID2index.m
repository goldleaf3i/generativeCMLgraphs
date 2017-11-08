function [ index ] = ID2index( ID )
%converto l'id di una label in un indice per le tabelle
switch ID
    case 100
        index=1;
    case 105
        index=2;
    case 5
        index=3;
    case 7
        index=4;
    case 6
        index=5;
    case 2
        index=6;
    case 10
        index=7;
    case 3
        index=8;
    case 0
        index=9;
    case 4
        index=10;
    case 1000
        index=11;
    case 11
        index=12;
    case 12
        index=13;
    case 13
        index=14;
    case 14
        index=15;
    case 15
        index=16;
    case 16
        index=17;
    case 17
        index=18;
    case 18
        index=19;
    case 19
        index=20;
    case 110
        index=21;
    case 1
        index=22;
    case 8
        index=23;
    case 9
        index=24;
    case 20
        index=25;
    otherwise
        index=26;
        
%     case 55 %CORRIDOR
%         index=5;
%     case 50 %HALL
%         index=4;
%     case 5 %GYM (AUDITORIUM)
%         index=12;
%     case 17 %CANTEEN
%         index=13;
%     case 13 %BIG SERVICE
%         index=8;
%     case 1 %SMALL
%         index=1;
%     case 12 %OFFICE 
%         index=7;
%     case 2 %CLASSROOM
%         index=2;
%     case 11%SMALL SERVICE
%         index=6;
%     case 3 %BIG FUNCTIONAL(LAB)
%         index=3;
%     case 1000 %ENTRANCE
%         index=9;
%     case 60 %WASHROOM 
%         index=11;
%     case 15 %BATROOM 
%         index=10;
%     otherwise
%         index=1;
        
end


end

