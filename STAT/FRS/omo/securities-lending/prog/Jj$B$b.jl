using Serialization
using Dates
using Plots
#trade & settle| sec | fee | mark sec| mark collateral| par amt of sec
#Date          | desc| rate| USD     | USD            | 1_000_000 USD  
J = sortslices(Serialization.deserialize("I")[:,[2,9,11,7,14,6]],dims=1) |>
x-> hcat(
x[:,1], #=trade & settle date=#
getindex.(x[:,2],[1:3]), #=issuer & kind of bond=#
round.(Int,8*parse.(Float64, getindex.(x[:,2],[5:10]) )), #=coupon, num(ber) of 1/800=#
Date.( getindex.(x[:,2],[12:21]) ), #=sec maturity date=#
x[:,3:6])

j=hcat(
J[:,1:2],
J[:,3]//800,
J[:,4:5],
J[:,6] .// J[:,8] .// 1_000_000, #=¢ per bond face $=#
J[:,7] .// J[:,8] .// 1_000_000) #=¢ per bond face $=#

for u in sort(unique(J[:,2]))
	# B .= J[findall(J[:,2] .== $.(B)),[1;3:7]]
	eval(Meta.parse(" $u = J[findall(J[:,2] .== \"$u\"),[1;3:8]] ") )
	l = lowercase(u)
	eval(Meta.parse(" $l = j[findall(j[:,2] .== \"$u\"),[1;3:7]] ") )
	# b .= j[findall(j[:,2] .== $.(B)),[1;3:7]]
end

B = sort(unique(J[:,2])) # .|>Symbol ???
b = lowercase.(sort(unique(J[:,2]))); # .|>Symbol ???

histogram(
J[:,7] .// J[:,6],ylabel="count",
title="Histogram of Collateralization Rate Observations",label=false)

plot(
xlabel="rank",
sort(J[:,7] .// J[:,6] ), ylabel="collateralization rate",
title="Collateralization Rate, Order Statistic",label=false)

plot(
(1:size(J,1)) .//size(J,1), xlabel="rank/$(size(J,1))", xticks=1//11:2//11:1//1,
sort(J[:,7] .// J[:,6] ), ylabel="collateralization rate",
title="Collateralization Rate, Embedded Order Statistic",legend=false)

histogram(
xlabel="count of unique Collateralization rate",ylabel="count",
sort(J[:,7] .// J[:,6])|>(x-> [1;1 .+ findall(x[2:end,1] .!= x[1:end-1,1]);size(x,1)+1]|>diff),
title="Histogram of Counts of Unique Collateralization Rates")

#----
histogram(
j[:,5],ylabel="count",
title="Histogram of Lending Fee Rates",label=false)

plot(
xlabel="rank",
sort(j[:,5]), ylabel="lending fee rate",
title="Lending Fee Rate, Order Statistic",label=false)

plot(
(1:size(J,1)) .//size(J,1), xlabel="rank/$(size(J,1))", xticks=1//11:2//11:1//1,
sort(j[:,5]), ylabel="lending fee rate",
title="Lending Fee Rate, Embedded Order Statistic",legend=false)

histogram(
xlabel="count of unique lending fee rate",ylabel="count",
sort(j[:,5])|>(x-> [1;1 .+ findall(x[2:end,1] .!= x[1:end-1,1]);size(x,1)+1]|>diff),
title="Histogram of Counts of Unique Lending Fee Rates")

plot(
sort(J[:,5]), xlabel="ranked lending fee rates",
sort(J[:,7] .// J[:,6]),ylabel="ranked collateralization rates",
legend=false)

scatter(
J[:,5], xlabel="lending fee rate",
J[:,7] .// J[:,6],ylabel="collateralization rates",
legend=false)

let r = findall(J[:,5] .> 1//2000);
scatter(
J[r,5], xlabel="lending fee rate",
J[r,7] .// J[r,6],ylabel="collateralization rates",
legend=false,ms=0.7)
end

let r = J[:,5] .> 1//2000;
scatter3d(
J[r,5], xlabel="lending fee rate",
J[r,7] .// J[r,6],ylabel="collateralization rates",
j[r,6],zlabel="fed's mark to mrkt of security ¢ per bond face \$ ",
markeralpha=j[r,3],
legend=false,ms=0.7,size=(1000,800))
end

let r = findall(J[:,5] .> 1//2000)[1:1000];
scatter3d(j[r,3],J[r,7] .// J[r,6],j[r,6], 
markerstrokecolor=J[r,3],ms=0.7,size=(1000,900))
end

histogram(
j[findall(j[:,5] .== 1//2000),6],xlabel="¢ per par \$",
ylabel="count",
title="Mrkt Val of Bonds Lent (lending fee rate = 5bps)",size=(600,600),legend=false)

histogram(
j[findall(j[:,5] .> 1//2000),6],xlabel="¢ per par \$",
ylabel="count",
title="Mrkt Val of Bonds Lent (lending fee rate > 5bps)",size=(600,600),legend=false)

scatter(
j[findall(j[:,5] .> 1//2000),6],xlabel="¢ per par \$",
j[findall(j[:,5] .> 1//2000),5],ylabel="lending fee rate",
title="Bonds Lent (lending fee rate > 5bps)",legend=false,ms=0.7)


anim = Animation()
for bins in 30:5:300
	p=histogram2d(
	j[findall(j[:,5] .> 1//2000),6],xlabel="cents per par \$",xlims=(80,200),
	j[findall(j[:,5] .> 1//2000),5],ylabel="lending fee rate",ylims=(0,0.06),
	title="Bonds Lent (fee rate > 5bps)",nbins=bins,size=(1200,600))
	frame(anim)
end
gif(anim,"diswork?.gif",fps=10)

sortslices(j[findall(j[:,5] .> 1//2000),[6;5]],dims=1)|>
(K->let a = [ 1 ; filter(i-> K[i,:] != K[i-1,:] , 2:size(K,1) ) ; size(K,1)+1]
	return [K[a[1:end-1],:] diff(a)]
end)|>
(K->scatter3d(eachcol(K)...,size=(1000,900),ms=0.7))

function topdot(A::Array;_sz=(900,700),_ms=0.9,_lb="",xlb="",ylb="",zlb="")
	if size(A,2) == 2
		B = sortslices(A,dims=1)
		z = [ 1 ; filter(i-> B[i,:] != B[i-1,:] , 2:size(A,1) ) ; size(A,1)+1]
		scatter3d(
			B[z[1:end-1],1],
			B[z[1:end-1],2], 
			diff(z),
			size=_sz,ms=_ms,label=_lb,xlabel=xlb,ylabel=ylb,zlabel=zlb)
	elseif size(A,2) == 1
		B = sort(A);
		z = [1 ; filter(i-> A[i] != A[i-1], 2:size(A,1)) ; size(A,1)+1];
		scatter(
			B[z[1:end-1],1],
			diff(z),
			size=_sz,ms=_ms,label=_lb,xlabel=xlb,ylabel=ylb,zlabel=zlb)
	end
end

function topdot!(A::Array;_sz=(900,700),_ms=0.9,_lb="")
	if size(A,2) == 2
		B = sortslices(A,dims=1)
		z = [ 1 ; filter(i-> B[i,:] != B[i-1,:] , 2:size(A,1) ) ; size(A,1)+1]
		scatter3d!(
			B[z[1:end-1],1],
			B[z[1:end-1],2],
			diff(z),
			size=_sz,ms=_ms,label=_lb)
	elseif size(A,2) == 1
		B = sort(A)
		z = [1 ; filter(i-> A[i] != A[i-1], 2:size(A,1)) ; size(A,1)+1]
		scatter!(
			B[z[1:end-1],1],
			diff(z),
			size=_sz,ms=_ms,label=_lb)
	end
end

topdot(j[filter( i -> (j[i,5] > 1//2000) && (j[i,3]==0),axes(j,1) ),[6;5]],_sz=(900,700),xlb="cents per \$ par",ylb="lending fee rate",zlb="count")


topdot(j[filter( i -> (j[i,5] > 1//2000) && (j[i,3]==0) && 94<j[i,6]<106,axes(j,1) ),[6;5]],_sz=(900,700),_lb="0 coupon",xlb="cents per \$ par",ylb="lending fee rate",zlb="count")
topdot!(j[filter( i -> (j[i,5] > 1//2000) && (j[i,3]!=0) && 94<j[i,6]<106,axes(j,1) ),[6;5]],_lb="non 0 coupon")


(topdot(j[filter( i -> (j[i,5] > 1//2000) && (j[i,3]==0) && 94<j[i,6]<106,axes(j,1) ),[6;5]],
	_sz=(900,700),_lb="0 coupon",xlb="cents per \$ par",ylb="lending fee rate",zlb="count");
for c in 1:10
	tmp = j[filter( i -> (j[i,5] > 1//2000) && (94<j[i,6]<106) && ((c-1)//100 <j[i,3]<= c//100),axes(j,1) ),[6;5]]; if size(tmp,1)>2 
	topdot!(tmp,_lb="$(c-1) < coupon % <= $c")
	end
end; plot!())

#noting
histogram(ans[:,3])

findall(94 .< j[:,6] .< 106)|>(x->scatter3d(j[x,1],j[x,3] .- j[x,1],j[x,5])) 

findall( (94 .< j[:,6] .< 106) .& (j[:,5] .> 1//2000) )|>
(x -> scatter3d(
	j[x,1],
	j[x,4] .- j[x,1],
	j[x,5],
	ms=0.7,size=(1000,900), marker_z=j[x,3]*100))

findall( (94 .< j[:,6] .< 106) .& (j[:,5] .> 1//2000) )[1:1000]|>
(x -> scatter3d(
	j[x,1],
	j[x,4] .- j[x,1],
	j[x,5],
	ms=0.7,size=(1000,900), marker_z= j[x,3]*100,color_palette=palette(:blues))) #can also round(j[x,3]*100,RoundUp)

findall( (94 .< j[:,6] .< 106) .& (j[:,5] .> 1//2000) )[1:2000]|>
(x -> scatter3d(
	j[x,1],
	j[x,4] .- j[x,1],
	j[x,5],
	ms=0.7,size=(800,800), marker_z=round.(j[x,3]*100,RoundUp),color_palette=cgrad(:blues,13)))
#cgrad(:blues,13) prolly faster than palette(:blues)
#nonetheless any color_palette slows down fig creation hella... :/
# clibraries() for color libraries

plot(); for c in 1:10
findall(  (94 .< j[:,6] .< 106) .& (j[:,5] .> 1//2000) .& ( (c-1)//100 .< j[:,3] .<= c//100))|>
(x -> scatter3d!(
	j[x,1],
	j[x,4] .- j[x,1],
	j[x,5],
	ms=0.9,size=(1000,800),label="$(c-1)<coupon %<$c",legendfontsize=12,legend=:right))
end; plot!()

plot(); for c in 1:10 
findall(  (j[:,5] .> 1//2000) .& ( (c-1)//100 .< j[:,3] .<= c//100))|>
(x -> scatter3d!(
	j[x,1],
	j[x,4] .- j[x,1],
	j[x,5],
	ms=0.9,size=(1000,800),label="$(c-1)<coupon %<$c",legendfontsize=12,legend=:right))
end; plot!()

plot(); for c in 0:10 
findall(  (j[:,5] .> 1//2000) .& ( (c-1)//100 .< j[:,3] .<= c//100))|>
(x -> scatter3d!(
	j[x,1],
	j[x,4] .- j[x,1],
	j[x,6],
	ms=0.9,size=(1000,800),label="$(c-1)<coupon %<$c",legendfontsize=12,legend=:right))
end; plot!()


findall(11//100 .>= j[:,3] .>10//100)|>(x->scatter3d(j[x,1],j[x,4] .- j[x,1],j[x,6],
       label="10<coupon%<=11",
       ms=0.9,size=(1000,900),legend=:right))

plot();for c in 1:12
findall(c//100 .>= j[:,3] .>(c-1)//100)|>
(x->scatter3d!(
	j[x,1], xticks=Date("2010"):Year(1):Date("2022"),
	j[x,4] .- j[x,1], yticks=Year(0):Year(2):Year(30),
	j[x,6], zlabel="cents per \$ par",
    label="$(c-1)<coupon%<=$c",
	ms=0.7,size=(1000,900),legend=:right,color=cgrad(:plasma,12)[c]))
end;plot!()

