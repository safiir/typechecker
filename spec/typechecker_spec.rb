require "set"
require "typechecker"

class B; end
class A < B; end
class D; end
class C < D; end
    
class M
    sig
    def fun()
      []
    end
    
    sig Integer
    def fun(p1)
      [p1]
    end
    
    sig Integer, Integer
    def fun(p1, p2)
      [p1, p2]
    end
    
    sig Integer, Integer, Integer
    def fun(p1, p2, p3)
      [p1, p2, p3]
    end
    
    sig String, String, String
    def fun(p1, p2, p3)
      [p1, p2, p3].join(", ")
    end
    
    sig Array, Array, Array
    def fun(p1, p2, p3)
      [p1, p2, p3].reduce(:+)
    end
    
    sig Hash, Hash
    def fun(p1, p2)
        fun(p1, p2, {})
    end
    
    sig Hash, Hash, Hash
    def fun(p1, p2, p3)
      [p1, p2, p3].reduce(:merge)
    end
    
    sig Set, Set, Set
    def fun(p1, p2, p3)
      [p1, p2, p3].reduce(:+)
    end
    
    sig A, D
    def ambiguous(a, d)
      [A, D]
    end

    sig B, C
    def ambiguous(b, c)
      [B, C]
    end

    sig A, C
    def poly(a, c)
      [A, C]
    end

    sig B, D
    def poly(b, d)
      [B, D]
    end
end

RSpec.describe TypeChecker do
  it "it should work well in basic overloading via the size of the parameter" do
    expect(M.new.fun()).to eq []
    expect(M.new.fun(1)).to eq [1]
    expect(M.new.fun(1, 2)).to eq [1, 2]
    expect(M.new.fun(1, 2, 3)).to eq [1, 2, 3]
    expect{
      M.new.fun(1, 2, 3, 4)
    }.to raise_error NoMethodError
  end

  it "it should work well in overloading via the parameter type" do
    expect(M.new.fun("A", "B", "C")).to eq "A, B, C"
    expect(M.new.fun([1], [2], [3])).to eq [1, 2, 3]
    expect(M.new.fun({a: 1}, {b: 2}, {c: 3})).to eq ({a: 1, b: 2, c: 3})
    expect(M.new.fun(Set.new([1]), Set.new([2]), Set.new([3]))).to eq Set.new([1, 2, 3])

    expect{
      M.new.fun(:a, :b, :c)
    }.to raise_error NoMethodError
  end

  it "it should raise an ambiguous method call exception" do
    expect{
      M.new.ambiguous(A.new, C.new)
    }.to raise_error TypeChecker::Err::AmbiguousMethodCall
  end

  it "it should automatch the most concrete definition to invoke" do
    expect(M.new.poly(A.new, C.new)).to eq [A, C]
  end

  it "it should throw an exception when the duplicate signature declared" do
    expect{
      class DupSig
        sig String
        sig String
        def invoke(a)
        end
      end
    }.to raise_error TypeChecker::Err::DuplicateSignature
  end

  it "it should throw an exception when inconsistent signature&implementation occurs" do
    expect{
      class InconsistentClazz
        sig String
        def invoke(a, b)
        end
      end
    }.to raise_error TypeChecker::Err::Inconsistent
  end

  it "it should throw an exception when duplicate defintion occurs" do
    expect{
      class DuplicateDefinition
        sig String
        def invoke(a)
        end

        sig String
        def invoke(a)
        end
      end
    }.to raise_error TypeChecker::Err::ConflictDefinition
  end
end