function [hg1, hg2, hg3, hg3x1, hg3x2, dconn, hgo1, hgo2, y] = GAB(X)

    gamma = 10;
    
    H = eye(6);
    
    P2 = [1/(0.3)^2 0; 0 1/(0.1)^2];
    P3 = [1/(0.3)^2 0; 0 1/(0.35)^2];

    c3 = 0.9; c4 = 0.7; c5 = 0.8; c6 = -0.7; c7 = -1; c8 = 0.4; c9 = 0.3; c10 = 0;
    
    zero = [0 0;0 0];
    C2 = [c3; c4];
    C3 = [c5; c6];
    C2g3 = [c7; c8];
    Cobs = [c9; c10];
    
    P_2 = [P2 zero zero; zero zero zero; zero zero zero];
    P_3 = [zero zero zero; zero P2 zero; zero zero zero];
    P_4 = [P3 zero zero; zero zero zero; zero zero zero];
    P_5 = [zero zero zero; zero P3 zero; zero zero zero];
    
    norm21 = norm(X(1:2) - X(3:4));
    dconn = (X(3) + 0.8)^2 + 0.2;
 
    hg1 = 1 - (X - [C2; 0; 0; 0; 0])'*P_2*(X - [C2; 0; 0; 0; 0]);                       % Goal for Robot 1
    hg2 = 1 - (X - [0; 0; C3; 0; 0])'*P_3*(X - [0; 0; C3; 0; 0]);                       % Goal for Robot 2
    hgo1 = (X - [Cobs; 0; 0; 0; 0])'*P_4*(X - [Cobs; 0; 0; 0; 0]) - 1;
    hgo2 = (X - [0; 0; Cobs; 0; 0])'*P_5*(X - [0; 0; Cobs; 0; 0]) - 1;

    hg3x1 = 1 - (X - [C2g3; 0; 0; 0; 0])'*P_2*(X - [C2g3; 0; 0; 0; 0]);                 % Goal C for Robot 1
    hg3x2 = 1 - (X - [0; 0; C2g3; 0; 0])'*P_3*(X - [0; 0; C2g3; 0; 0]);                 % Goal C for Robot 2

    hg3 = dconn^2 - norm21^2;
    
    A3 = - [0, 0, (2*dconn)*(2*(X(3) + 0.8)^1), 0] - [2*(X(3) - X(1)), 2*(X(4) - X(2)), -2*(X(3) - X(1)), - 2*(X(4) - X(2))];
    A3 = [A3, 0, 0];
    A2 = 2*(X - [C2; 0; 0; 0; 0])'*P_2 + 2*(X - [0 ; 0; C3; 0; 0])'*P_3;
    A4 = -2*(X - [Cobs; 0; 0; 0; 0])'*P_4;
    A5 = -2*(X - [0; 0; Cobs; 0; 0])'*P_5;

    B2 = gamma*sign(min(hg1, hg2));
    B3 = gamma*hg3;
    B4 = gamma*hgo1^7;
    B5 = gamma*hgo2^7;

    a = [A2; A3; A4; A5];
    b = [B2; B3; B4; B5];
    
    opts = optimoptions(@quadprog, 'Display', 'off');
    y = quadprog(H, [], a, b, [], [], [], [], [], opts);
    
end