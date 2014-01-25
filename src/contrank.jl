# arithmetics on contiguous ranks

for m=0:3, n=0:3
    global addrank
    @eval addrank(::Type{ContRank{$m}}, ::Type{ContRank{$n}}) = ContRank{$(m+n)}
end

addrank{M,N}(::Type{ContRank{M}}, ::Type{ContRank{N}}) = ContRank{M+N}
addrank{N}(::Type{ContRank{0}}, ::Type{ContRank{N}}) = ContRank{N}
addrank{N}(::Type{ContRank{N}}, ::Type{ContRank{0}}) = ContRank{N}

for m=0:3, n=0:3
    global minrank
    @eval minrank(::Type{ContRank{$m}}, ::Type{ContRank{$n}}) = ContRank{$(min(m,n))}
end

minrank{M,N}(::Type{ContRank{M}}, ::Type{ContRank{N}}) = ContRank{min(M,N)}
minrank{N}(::Type{ContRank{0}}, ::Type{ContRank{N}}) = ContRank{0}
minrank{N}(::Type{ContRank{N}}, ::Type{ContRank{0}}) = ContRank{0}

for m=0:3, n=0:3
    global restrict_crank
    @eval restrict_crank(::Type{ContRank{$m}}, ::NTuple{$n,Int}) = ContRank{$(min(m,n))}
end

restrict_crank{M,N}(::Type{ContRank{M}}, ::NTuple{N,Int}) = ContRank{min(M,N)}
restrict_crank{N}(::Type{ContRank{0}}, ::NTuple{N,Int}) = ContRank{0}
restrict_crank{N}(::Type{ContRank{N}}, ::()) = ContRank{0}


# contiguous rank computation based on indices

_nprefixreals() = ContRank{0}
_nprefixreals(i::Real) = ContRank{1}
_nprefixreals(i::SubsRange) = ContRank{0}

_nprefixreals(i1::Real, i2::Real) = ContRank{2}
_nprefixreals(i1::Real, i2::SubsRange) = ContRank{1}
_nprefixreals(i1::SubsRange, i2::Subs) = ContRank{0}

_nprefixreals(i1::Real, i2::Real, i3::Real) = ContRank{3}
_nprefixreals(i1::Real, i2::Real, i3::Real, I::Subs...) = addrank(ContRank{3}, _nprefixreals(I...))
_nprefixreals(i1::Real, i2::Real, i3::SubsRange, I::Subs...) = ContRank{2}
_nprefixreals(i1::Real, i2::SubsRange, i3::Subs, I::Subs...) = ContRank{1}
_nprefixreals(i1::SubsRange, i2::Subs, i3::Subs, I::Subs...) = ContRank{0}

contrank() = ContRank{0}

contrank(i::Real) = ContRank{1}
contrank(i::Real, i2::Real) = ContRank{2}
contrank(i::Real, i2::Real, I::Subs...) = _nprefixreals(i, i2, I...)
contrank(i::Real, i2::SubsRange, I::Subs...) = ContRank{1}

contrank(i::Range, I::Subs...) = ContRank{0}

contrank(i1::Colon) = ContRank{1}
contrank(i1::Colon, i2::CSubs) = ContRank{2}
contrank(i1::Colon, i2::Range) = ContRank{1}

contrank(i1::Colon, i2::Colon, i3::Colon,  I::Subs...) = addrank(ContRank{3}, contrank(I...))
contrank(i1::Colon, i2::Colon, i3::Real,   I::Subs...) = addrank(ContRank{3}, _nprefixreals(I...))
contrank(i1::Colon, i2::Colon, i3::Range1, I::Subs...) = addrank(ContRank{3}, _nprefixreals(I...))
contrank(i1::Colon, i2::Colon, i3::Range,  I::Subs...) = ContRank{2}

contrank(i1::Colon, i2::Union(Real,Range1), I::Subs...) = addrank(ContRank{2}, _nprefixreals(I...))
contrank(i1::Colon, i2::Range, I::Subs...) = ContRank{1}

contrank(i1::Range1) = ContRank{1}
contrank(i1::Range1, i2::Real) = ContRank{2}
contrank(i1::Range1, i2::SubsRange, I::Subs...) = ContRank{1}

contrank(i1::Range1, i2::Real, i3::Real) = ContRank{3}
contrank(i1::Range1, i2::Real, I::Subs...) = addrank(ContRank{2}, _nprefixreals(I...))


# contiguous rank with array & arrayviews

contrank(a::Array, i1::Subs) = contrank(i1)
contrank(a::Array, i1::Subs, i2::Subs) = contrank(i1, i2)
contrank(a::Array, i1::Subs, i2::Subs, i3::Subs) = contrank(i1, i2, i3)
contrank(a::Array, i1::Subs, i2::Subs, i3::Subs, i4::Subs) = contrank(i1, i2, i3, i4)
contrank(a::Array, i1::Subs, i2::Subs, i3::Subs, i4::Subs, i5::Subs, I::Subs...) = contrank(i1, i2, i3, i4, i5, I...)

contrank{T,N}(a::ArrayView{T,N,N}, i1::Subs) = contrank(i1)
contrank{T,N}(a::ArrayView{T,N,N}, i1::Subs, i2::Subs) = contrank(i1, i2)
contrank{T,N}(a::ArrayView{T,N,N}, i1::Subs, i2::Subs, i3::Subs) = contrank(i1, i2, i3)
contrank{T,N}(a::ArrayView{T,N,N}, i1::Subs, i2::Subs, i3::Subs, i4::Subs) = contrank(i1, i2, i3, i4)
contrank{T,N}(a::ArrayView{T,N,N}, i1::Subs, i2::Subs, i3::Subs, i4::Subs, i5::Subs, I::Subs...) = contrank(i1, i2, i3, i4, i5, I...)

contrank{T,N,M}(a::ArrayView{T,N,M}, i1::Subs) = minrank(contrank(i1), ContRank{M})
contrank{T,N,M}(a::ArrayView{T,N,M}, i1::Subs, i2::Subs) = minrank(contrank(i1, i2), ContRank{M})
contrank{T,N,M}(a::ArrayView{T,N,M}, i1::Subs, i2::Subs, i3::Subs) = minrank(contrank(i1, i2, i3), ContRank{M})
contrank{T,N,M}(a::ArrayView{T,N,M}, i1::Subs, i2::Subs, i3::Subs, i4::Subs) = minrank(contrank(i1, i2, i3, i4), ContRank{M})
contrank{T,N,M}(a::ArrayView{T,N,M}, i1::Subs, i2::Subs, i3::Subs, i4::Subs, i5::Subs, I::Subs...) = 
	minrank(contrank(i1, i2, i3, i4, i5, I...), ContRank{M})

