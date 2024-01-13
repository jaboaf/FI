using Plots

# LEG note
#=
- 4th col ("Actual return date") and 12th col (Penalty fees) are aspects of the closing leg, observed after settlement.
- for a particular transaction: values in all other cols (not 4th or 12th) are established on or before (i.e. 'by') the 1stlegdate, the value in the 1st and 2nd column.
=#

# A focus (OPEN LEGs)
K = 
let J = sortslices(deserialize("I")[:,[2,9,11,6,7,14]],dims=1)
	# Reduction
	K = [J[1,:]]
	rcnt = J[1,1:3]
	frnt = iterate(eachrow(J),1)
	while frnt != nothing
		(hing,t) = frnt
		#if hing[1:3] == rcnt
		if hing[2]==rcnt[2] && hing[3]==rcnt[3] && hing[1]==rcnt[1]
			K[end][4:6] += hing[4:6]
			frnt = iterate(eachrow(J),t)
		else
			push!(K,hing)
			rcnt = hing[1:3]
			frnt = iterate(eachrow(J),t)
		end
	end
	K=permutedims(hcat(K...),[2,1]);
end

b = [1;filter(i->K[i,1] != K[i-1,1],2:size(K,1));size(K,1)+1]|>
x-> (:).( x[1:end-1], x[2:end] .-1)

d = unique(K[:,1]);
#=getindex broadcasting, e.g.
getindex.([K],b[1:2],:);
ans[1]==K[b[1],:] && ans[2]==K[b[2],:]
getindex.([K],b[1:2],[3:5]);
ans[1]==K[b[1],3:5] && ans[2]==K[b[2],3:5]
=#
fig=scatter(
	unique(K[:,1]),xlab="Date",
	length.(b),ylab="Number of Types of Securities",
	legend=false,title="Number of Types of Securities Lent on Openning Leg Dates",
	size=(960,600),dpi=120)
savefig(fig,"N(TypesOfSecuritiesLent(Date)).png")
savefig(fig,"N(TypesOfSecuritiesLent(Date)).html")

fig=scatter(
	d,xlab="Date",
	(getindex.([K],b,4).|>sum) * 1000000,ylab="Number of USD",
	legend=false,title="Par Value of Securities Lent on Openning Leg Dates",
	size=(960,600),dpi=120)
savefig("USDofParValue(SecuritiesLent(Date)).png")
savefig("USDofParValue(SecuritiesLent(Date)).html")

scatter(
	d,xlabel="Date"
	getindex.([K[:,6] .// K[:,5]],b) .|>(x-> count(<(51//50),x)//length(x)),
	label="Proportion of Type of Securities")
scatter!(
	d,
	getindex.([K],b,[4:6]).|>
	(x-> let l = findall(i-> x[i,3]//x[i,2] < 51//50,1:size(x,1));
       	length(l)==0 ? 0 : sum(x[l,1])//sum(x[:,1]) end),
	label="Proportion by Par Value")
scatter!(
	xlabel="Date",xticks=(Date(2011):Year(1):last(d)),
	ylims=(0,1),
	size=(960,600),dpi=120,title="Proportion of Securities Lent under 51/50 collateralization")

#@PICK BELOW OR ABOVE triplet
scatter(
	d,xlabel="Date",xticks=(Date(2011):Year(1):last(d)),
	getindex.([[(K[:,6] .// K[:,5]) K[:,4]]],b,:) .|> 
	[(x->count(x[:,1] .< 51/50)//size(x,1)) (x->let l = findall(x[:,1] .< 51//50); length(l)==0 ? 0//1 : sum(x[l,2])//sum(x[:,2]) end)],
	ylims=(0,1),
	label=["by Number of Type of Securities" "by Par Value of Securities"],
	size=(960,600),dpi=120,title="Proportion of Securities Lent under 51/50 collateralization")
savefig("ProportionofSecuritiesLentWithCollateralMarkOVERSecurityMarkLessThan51over50(Date)byNumberAndbyParValue.png")


let i = findall(first.(K[:,2]) .=='T') ∩ findall( 1//2000 .< K[:,3] )
scatter3d(
	K[i,1],xlabel="Date",xticks=Date(2011):Month(4):last(d)
	Date.(getindex.(K[i,2],[12:21])) .- K[i,1],ylabel="till maturity",
	K[i,3], zlabel="Lending Rate",
	title="date TSY{<:coupon,date + days{d}} LendingRate > 1/2000",
	size=(1200,800),ms=0.8)
end



#=
You dont have to restrict to TSY securities in the above plot nor to non 5bp lending rates but you get the picture
The idea of working with K was to
	'treat' primary dealers as equivalent (hence the integrated values)
	with the direction to the 'Fed Balance Sheet' or 'Primary Dealer Balance Sheet' perspective
	focusing a little makes shit easier so I figured why not focus on 'open legs'
	which is why "Actual return date" and "Penalty fees (in dollars, USD)" are omitted...
	sure there are those transactions that close an open leg
	but there are definately more 'legs'

On the NY Fed website Securties Lending FAQ, in ref to lending rate, *not a repo rate*
... emphasising (previously) that these securities lending agreements are not Repos or Reverse Repos
... true
... to no primary dealer nor the Fed does it constitute a
		'securities sold under an agreement to purchase' thing nor ('securities purchased under an agreement to sell' of course)
... yet
... the Fed:
		exchanges (its) securities for funds
		obligates to (re)exchange those funds
... so... 'funds purchased under an obligation to sell'
=#

# Abt TSY coupon securiteis (Notes, Bonds)
all(s->s[1:3] != "TSY" ||s[5:10]=="00.000" || s[20:21]=="15" || Date(s[12:21])==lastdayofmonth(Date(s[12:21])),K[:,2])
# Coupon Dates, t is asof date or first coupon date
# for TSY non-bills in scope maturity is the 15th day of a month or the last day of a month
# in the former case the coupon dates are 6 Calendar Months apart (also on the 15th)
# in the latter case the coupon dates are 6 Calendar Months apart and the last day of a month
function CouponDates(t,m)
	if Day(m)==Day(15)
		return collect(reverse(m:-Month(6):t)) #safe
	elseif m==lastdayofmonth(m)
		return lastdayofmonth.(reverse(m:-Month(6):t))
	else
		return [m]
	end
end
function NextCoupon(t,m)
	return first(CouponDates(t+Day(1),m))
end

# Narrow Focus a bit (to Non-Statistical Tresasury Marketable Securities)

#Restriction to Non-Statistical Tresasury Marketable Securities
#ie. TSY
KT= K[findall(first.(K[:,2]) .=='T'),:];

bT= filter(i->KT[i,1:2] != KT[i-1,1:2],2:size(KT,1))|>
x-> (:).([1;x],[x .- 1;size(KT,1)])

LT = [KT[first.(bT),1] round.(Int,parse.(Float64,getindex.(KT[first.(bT),2],[5:10])) ./ 0.125) Date.(getindex.(KT[first.(bT),2],[12:21])) vcat(sum.(getindex.([KT],bT,[4:6]),dims=1)...)]
#now we have: date couponrate*8 maturity faceval mrkval collateralval

# Further restriction to TSYs with coupons
TNC = sortslices([LT[:,1] NextCoupon.(LT[:,1],LT[:,3]) LT[:,3] LT[:,2] LT[:,4:6]],dims=1)
B = TNC[TNC[:,4] .!= 0,:]
BS=[1;filter(i->B[i,1:2]!=B[i-1,1:2],2:size(B,1));size(B,1)+1]|>
x-> (:).( x[1:end-1], x[2:end] .-1)

#see this pic of TSY paper

#Number of Bond or IO projections
#is the Maximum Number of Bond Projections
#is...
BS .|> length .|> (l->(l-1)*(l)/2) |>sum
#1_985_623 = Number of Bond or IO projections
#1_985_623 ≥ Number of Bond Projections
#@some ploppin sorta thing would be nice 

#Maximum Number of IO Projections
#also the likely the number of IO Projections
[0;(B[1:end-1,3] .== B[2:end,3]);0]|>diff|>(A->findall(==(-1),A) - findall(==(1),A)).|>(n->n*(n+1)/2)|>sum
#42_570 ≥ Number of IO Projections
#1_943_053 = 1_985_623-42_570 ≤ Number of Bond Projections ≤ 1_985_623

#just wanted to find these bounds before we do it bc it coulda been a lot lot lot bigger and i'm on a 2017 macbook air lol
B[BS[2],:]|>(X-> [[((X[b,6]//(X[b,5]*1_000_000))*X[a,4] - (X[a,6]//(X[a,5]*1_000_000))*X[b,4])//X[a,4] for b in a+1:size(X,1)] for a in 1:size(X,1)-1])

#@JOJO also demonstrate you can do it in the same length (num rows) by keeping the near bond and doing spreads to that for each relevant far one, and show how to compute the spreads of far under farther

P =[]
for bs in BS
	X=BS[bs,:]
	t=X[1]
	for a in 1:length(bs)-1
		for b in a:length(bs)
#@ DONT FORGET IOs exist.
			#((X[b,6]//(X[b,5]*1_000_000))*X[a,4] - (X[a,6]//(X[a,5]*1_000_000))*X[b,4])//X[a,4]
			#((X[b,6]//X[b,5]//1_000_000)*X[a,4] - (X[a,6]//X[a,5]//1_000_000)*X[b,4])//X[a,4]
			sab = (X[a,4]*X[b,6]//X[b,5]//1_000_000 - X[b,4]*X[a,6]//X[a,5]//1_000_000)//X[a,4]
			push!(P,(t,X[a,3],X[b,3],X[a,4],X[b,4]]))
		end
	end
end


println("GRAVEYARD THAT USED TO BE AT THE END OF THIS FILE AKA HERE IS NOW IN GRAVEYARD.txt")