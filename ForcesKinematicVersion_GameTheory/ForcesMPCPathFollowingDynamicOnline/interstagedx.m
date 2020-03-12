function dx = interstagedx(x,u,p)
    addpath('../TireAnalysis');
    global index
    
    Cf = p(index.pmoi); % moment of inertia    

    B1 = p(index.pB1);
    C1 = p(index.pC1);
    D1 = p(index.pD1);
    B2 = p(index.pB2);
    C2 = p(index.pC2);
    D2 = p(index.pD2);
    
%     B1 = 9;  
%     C1 = 1;     
%     D1 = 10;   
%     B2 = 5.2;
%     C2 = 1.1;     
%     D2 = 20;


    param = [B1,C1,D1,B2,C2,D2,Cf];

    %disp(param)
    
    %[ab,dotbeta,ds,brake / x,y,theta,v,beta,s,braketemp]
    %evolution:
    %maxacc = casadiGetMaxAcc(x);
    %minacc = casadiGetMaxNegAcc(x);
    %ab = 0.5*(maxacc-minacc)*(u(1)+1);
    dotab = u(index.dotab);
    ab = x(index.ab-index.nu);
    tv = u(index.tv);
    dotbeta = u(index.dotbeta);
    ds = u(index.ds);
    %ds = 0.03;
    theta = x(index.theta-index.nu);
    vx = x(index.v-index.nu);
    vy = x(index.yv-index.nu);
    dottheta = x(index.dottheta-index.nu);
    beta = x(index.beta-index.nu); % from steering.
    %beta = 0;
    %temp = x(index.braketemp-index.nu);
    %braking=max(0,-ab+casadiGetMaxNegAcc(speed));
    %brakingheatup = heatupfunction(-ab-1.5);
    %brakingcooldown = cooldownfunction(temp);
    %l = 1.19; %todo unused
    ackermannAngle = -0.63.*beta.*beta.*beta+0.94*beta; %ackermann Mapping 
   
    %(VELX,VELY,VELROTZ,BETA,AB,TV, paramPacj)
    %[ACCX,ACCY,ACCROTZ,frontabcorr] = modelDx(vx,vy,dottheta,ackermannAngle,ab,tv, paramPacj);
    
    
    [ACCX,ACCY,ACCROTZ] = modelDx(vx,vy,dottheta,ackermannAngle,ab,tv, param);
    
    
    import casadi.*
    if isa(x(1), 'double')
        dx = zeros(index.ns,1);
    else
        dx = SX.zeros(index.ns,1);
    end
    rotmat = @(beta)[cos(beta),-sin(beta);sin(beta),cos(beta)];
    lv = [vx;vy];
    gv = rotmat(theta)*lv;
    dx(index.x-index.nu)=gv(1);
    dx(index.y-index.nu)=gv(2);
    dx(index.dottheta-index.nu)=ACCROTZ;
    dx(index.theta-index.nu)=dottheta;
    %dx(index.theta-index.nu)=vx/l*tan(ackermannAngle);
    dx(index.v-index.nu)=ACCX;
    dx(index.yv-index.nu)=ACCY;
    dx(index.beta-index.nu)=dotbeta;
    dx(index.s-index.nu)=ds;
    %dx(index.braketemp-index.nu)=brakingheatup+brakingcooldown;
    dx(index.ab-index.nu)=dotab;
    
    %dx = [v*cos(theta);
    %v*sin(theta);
    %v/l*tan(ackermannAngle);
    %ab;
    %dotbeta;
    %ds;
    %braking+cooldownfunction(temp)];
end

