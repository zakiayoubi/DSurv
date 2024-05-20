import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Prelude "mo:base/Prelude";


actor Token {
    let owner : Principal = Principal.fromText("y77rw-mchpl-kxbrw-mrz4o-mgqa5-sn4q5-jmqc7-ytgvk-bcf6t-becdf-vqe");
    let totalSupply : Nat = 1000000000;
    let symbol : Text = "DZAK";

    private stable var balanceEntries: [(Principal, Nat)] = [];

    // we create a ledge to store the user's id and amount of token
    private var balances = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);
    if (balances.size() < 1) {
        balances.put(owner, totalSupply);
    };

    public query func balanceOf(who: Principal): async Nat {

        let balance : Nat = switch (balances.get(who)) {
            case null 0;
            case (?result) result;
        };
        return balance;
    };

    public query func getSymbol(): async Text {
        return symbol;
    };

    public shared(msg) func payOut(): async Text {
        // Debug.print(debug_show(msg.caller));
        if (balances.get(msg.caller) == null) {
            let amount = 10000;
            let result = await transfer(msg.caller, amount);
            return result;
        } else {
            return "Already Claimed"
        }
    };

   public shared(msg) func transfer(to: Principal, amount: Nat): async Text {
        let fromBalance = await balanceOf(msg.caller);
        if (fromBalance > amount) {
            let newFromBalance: Nat = fromBalance - amount;
            balances.put(msg.caller, newFromBalance);

            let toBalance = await balanceOf(to);
            let newToBalance = toBalance + amount;
            balances.put(to, newToBalance);
            return "success"
        } else {
            return "Insufficient Funds"
        }
    
   };

   system func preupgrade() {
    balanceEntries := Iter.toArray(balances.entries());
   };

   system func postupgrade() {
    balances := HashMap.fromIter<Principal, Nat>(balanceEntries.vals(), 1, Principal.equal, Principal.hash);
    if (balances.size() < 1) {
        balances.put(owner, totalSupply);
    }
   };
}