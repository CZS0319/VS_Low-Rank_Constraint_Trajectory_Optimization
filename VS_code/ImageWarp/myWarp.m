function warpIm = myWarp(minx,maxx,miny,maxy,im,warpIm,invH,gap)

    [h,w,~] = size(warpIm);
    
    if gap > 0
        minx = max(floor(minx), 1-gap);
        miny = max(floor(miny), 1-gap);
    else
        minx = max(floor(minx),1);
        miny = max(floor(miny),1);
    end
    
    if minx > w - gap || miny > h - gap
        return;
    end
    
    maxx = min(ceil(maxx),w - gap + 1);
    maxy = min(ceil(maxy),h - gap + 1);

    szIm = [maxy-miny+1,maxx-minx+1];
    [x,y] = meshgrid(minx:maxx,miny:maxy);
    pix   = [x(:), y(:)];
    hPixels = [ pix, ones(prod(szIm),1)];
    hScene  = hPixels*invH;
    xprime=hScene(:,1)./hScene(:,3);
    yprime=hScene(:,2)./hScene(:,3);
    
    xprime = reshape(xprime, szIm);
    yprime = reshape(yprime, szIm);
    
    % result = interp2(im,xprime,yprime,'cubic');
    
  % use spline interpolation for better quality with lower speed
  result(:,:,1) = interp2(im(:,:,1),xprime,yprime,'linear');
  result(:,:,2) = interp2(im(:,:,2),xprime,yprime,'linear');
  result(:,:,3) = interp2(im(:,:,3),xprime,yprime,'linear');
    
  % warpIm(miny+gap:maxy+gap,minx+gap:maxx+gap)=result;

  warpIm(miny+gap:maxy+gap,minx+gap:maxx+gap,1) = result(:,:,1);
  warpIm(miny+gap:maxy+gap,minx+gap:maxx+gap,2) = result(:,:,2);
  warpIm(miny+gap:maxy+gap,minx+gap:maxx+gap,3) = result(:,:,3);
end