function grad = fd(fcn,xfd,coefs,diffN)

dx = xfd(2) - xfd(1);

yfd = fcn(xfd,0);
grad = sum(coefs.*yfd)/(dx^diffN);