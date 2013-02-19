-module(bank).
-compile(export_all).

-record(account, {id, name, balance = 0}).

start() ->
    spawn(?MODULE, command, [[]]).
    
command(EventList) ->
    receive
        {From, {create, {Name, Balance}}} ->
            Id = lists:count(account(EventList)),
            command(EventList ++ {create, {Id, Name, Balance}});
        {From, Command} ->
            command(EventList ++ Command);
    terminate ->
        ok
    end.

account(EventList) ->
    account(EventList, []).

account([], AccountList) ->
    AccountList;

account([{create, {Id, Name, Balance}}|T], AccountList) ->
    AccountList ++ [account(T, account(create, Id, Name, Balance))];
    
account([{withdraw, {Id, Balance}}|T], AccountList) ->
    OldAccount = account(Id, AccountList),
    NewBalance = OldAccount#account.balance + Balance,
    NewAccount = OldAccount#account{balance=NewBalance},
    AccountList -- OldAccount ++ account(T, NewAccount);
    
account([_|T], AccountList) ->
    account(T, AccountList);
    
account(Id, AccountList) ->
    lists:filter(fun(X) -> X#account.id == Id end, AccountList).
    
account(create, Id, Name) ->
    account(create, Id, Name, 0).
    
account(create, Id, Name, Balance) ->
    #account{id=Id, name=Name, balance = Balance}.