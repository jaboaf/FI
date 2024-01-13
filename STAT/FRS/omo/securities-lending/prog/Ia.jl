# ascertaining

using Serialization; I = deserialize("I"); #coulda used any unused valid identifier name...

#=Question
does variation in
values of X: "Settlement date" "Term (in days)" "CUSIP" "Lending fee (in percent)" "Par amount lent (in millions, USD)"
account for variation in
values of Y: "Market value of security Lent (in millions, USD)"
?=#
# a pair of observations (x,y),(x',y') where x=x' but y!=y' would be a counterexample
sortslices(I[:,[2,5,10,11,6,7]],dims=1)|>
x->findall(i-> x[i,1:5]==x[i+1,1:5] && x[i,6]!=x[i+1,6] ,1:size(x,1)-1)
#=same as
sortslices(I[:,[2,5,10,11,6,7]],dims=1)|>
x->findall(i->!(all(x[i,1:5] .== x[i+1,1:5]) ? x[i,6]==x[i+1,6] : true),1:size(x,1)-1)
=#
#recall, P ∧ ¬Q ≡ ¬(¬P ∨ ¬¬Q) ≡ ¬(¬P ∨ Q) ≡ ¬(P⟹Q) ≡ P⟹̸Q
@assert size(ans,1)!=0
#=A:
NO: sometimes Y changes and X does not
ie. variation in X does not imply variation in Y
=#

#i.e.
#mrktvalofseclent is NOT a function of 1stlegdate,term,security,lendingfeerate,amtofsecurity
#(same as above but outputs subarray of I where for each row there is another row with the same values in the first 5 columns but not the last)
sortslices(I[ : , [2,5,10,11,6,7] ],dims=1)|>
x-> let a = findall(i-> x[i,1:5]== x[i+1,1:5] && x[i,6]!=x[i+1,6],1:size(x,1)-1)
x[sort([a ; a .+ 1]),:]
end
@assert size(ans,1)!=0


#mrktvalofseclent is NOT a function of 1stlegdate,term,security,lendingfeerate,amtofsecurity,collateralval
sortslices(I[:,[2,5,10,11,6,14,7]],dims=1)|>
x-> let a = findall(i-> x[i,1:6]==x[i+1,1:6] && x[i,7]!=x[i+1,7] ,1:size(x,1)-1)
x[sort([a ; a .+ 1]),:]
end
#=same as
sortslices(I[:,[2,5,10,11,6,14,7]],dims=1)|>
x->findall(i->!(all(x[i,1:6] .== x[i+1,1:6]) ? x[i,7]==x[i+1,7] : true), 1:size(x,1)-1)
=#
@assert size(ans,1) !=0


#collateralval of securities lent is NOT a function of 1stlegdate,term,security,lendingfeerate,amtofsecurity,mrktvalofseclent
sortslices(I[:,[2,5,10,11,6,7,14]],dims=1)|>
x-> let a = findall(i-> x[i,1:6]==x[i+1,1:6] && x[i,7]!=x[i+1,7] ,1:size(x,1)-1)
x[sort([a ; a .+ 1]),:]
end
#=same as
sortslices(I[:,[2,5,10,11,6,7,14]],dims=1)|>
x->findall(i->!(all(x[i,1:6] .== x[i+1,1:6]) ? x[i,7]==x[i+1,7] : true),1:size(x,1)-1)
=#
@assert size(ans,1) != 0
# there is exactly one case when collateralval is not fixed by 1stlegdate,term,security,lendingfeerate,amtofsecurity,mrktvalofseclent


#BUT collateralval is a function of 1stlegdate,term,security,lendingfeerate,amtofsecurity,mrktvalofseclent,counterparty
#which you can observe from the sole counter example we found but why not put that in parallel structure
sortslices(I[:,[2,5,10,11,6,7,13,14]],dims=1)|>
x->let a = findall(i-> x[i,1:7]==x[i+1,1:7] && x[i,8]!=x[i+1,8] ,1:size(x,1)-1)
x[sort([a ; a .+ 1]),:]
end
@assert length(ans)==0
#and likewise if we swap the last two columns



# Invertible Freedoms!

@assert (I[:,1]==I[:,2]) "!(I[:,1]==I[:,2])"
#... so we can drop 1st or 2nd col

@assert (getproperty.(I[:,3]-I[:,2], :value) == I[:,5]) "!((I[:,3]-I[:,2]) == I[:,5])"
#... so keep two of 1st=2nd,3rd,5th col.

@assert size(unique(I[:,[2,5]],dims=1),1) == length(unique(unique(I[:,[2,5]],dims=1)[:,1])) "size(unique(I[:,[2,5]],dims=1),1) != length(unique(I[:,[2,5]],dims=1)[:,1])"
#... so dropping 5th col is invertivle
#... i.e. term is a function of 1stlegdate, the 2nd column

@assert size(unique(I[:,[8,9]],dims=1),1) == length(unique(unique(I[:,[8,9]],dims=1)[:,2])) "size(unique(I[:,[8,9]],dims=1),1) != length(unique(unique(I[:,[8,9]],dims=1)[:,2]))"
#... so dropping 8th col is invertible
#... i.e. issuer is a function of securitydescription 
@assert size(unique(I[:,[8,10]],dims=1),1) == length(unique(unique(I[:,[8,10]],dims=1)[:,2]))
#... so dropping 8th col is invertible
#... i.e. issuer is a function of cusip

@assert size(unique(I[:,[9,10]],dims=1),1) == length(unique(unique(I[:,[9,10]],dims=1)[:,1])) == length(unique(unique(I[:,[9,10]],dims=1)[:,2]))
#... there is a one-to-one correspondence between cusip and securitydescription (as one would hope)
#... so, keeping excatly one of 9th or 10th col and dropping the other, is invertible

# the last section demonstrates the columns of I absent throughout the entire first section do not alter the dependency structure of the **open leg** of securities-lending transactions

#if you want a recipie:
#- drop 1st, (keeping 2nd)
#- drop 3rd, (keeping 2nd and 5th)
#- drop 5th,
#- drop 8th, (keeping 9th and 10th)
#- drop 9th,
#- remaining are: 6th,7th,11th,12th,13th,and 14th
#- 12th is penalty fees, which is not an aspect of the open leg.
#- leaving us with the 2nd,6th,7th,11th,12th,13th,and 14th
#all of which appear in the first section

#... while we held onto the 5th column throughout the first section it was not nessesary to do so. (reacall: trade date implies term of securities loan)


# appearance of closing leg action

@assert any( (I[:,3] .!= I[:,4]) .!=  (I[:,12] .!= 0))
#... so late return does not imply or is not implied by non-zero penalty
@assert all( I[findall(I[:,3] .!= I[:,4]),12] .!= 0 )==false
#... so late return does not imply non-zero penalty
#... therefore, non-zero penalty implies late return.
#but lets confirm that:
@assert all((I[findall(I[:,12] .!= 0),3] .!= I[findall(I[:,12] .!= 0),4]))
#... so non-zero penalty implies late return (as it should)


# bingo, be a friend tell a friend somethin nice it might change their life