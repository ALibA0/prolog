% Made by Adam Korolev from НПИбд-02-21

implement main
    open core, file, stdio

domains
    cstatus = vip; regular; loyal.

class facts - bmarket
    goods : (integer PiD, string PName, integer PCost, string PType, string PProhibition).
    clients : (string CLName, string CLNum, cstatus CLStatus).
    purchase : (string CLNum, string PDate, integer PiD, integer PAmount).
    shipment : (string Country, string DStatus).

class facts
    s : (real Sum) single.

clauses
    s(0).

class predicates
    prodphob : (string PName) failure.
    shipment_list : (string Country) failure.
    sum_purchase_date : (string PDate) failure.
    clients_by_status : (cstatus CLStatus) failure.
    customer_expenses : (string CLName) failure.
    len : (Lst*) -> integer N.
    max : (integer* Lst, integer Max [out]) nondeterm.
    min : (integer* Lst, integer Min [out]) nondeterm.
    sum : (integer* Lst) -> integer S.
    average : (integer* Lst) -> real A determ.
    data : (main::bmarket*) nondeterm.
    by_status : (cstatus G) -> main::bmarket* ByStatus nondeterm.
    sum_price : () -> integer Sum.
    max_price : () -> integer Max determ.
    min_price : () -> integer Min determ.

clauses
    len([]) = 0.
    len([_ | T]) = len(T) + 1.

    sum([]) = 0.
    sum([X | T]) = sum(T) + X.

    max([Max], Max).
    max([X, Y | T], Max) :-
        X >= Y,
        max([X | T], Max).
    max([X, Y | T], Max) :-
        X < Y,
        max([Y | T], Max).

    min([Min], Min).
    min([X, Y | T], Min) :-
        X <= Y,
        min([X | T], Min).
    min([X, Y | T], Min) :-
        X > Y,
        min([Y | T], Min).

    average(Lst) = sum(Lst) / len(Lst) :-
        len(Lst) > 0.

    % Вывод данных
    data([X | T]) :-
        write(X),
        nl,
        data(T).

    by_status(CLStatus) = ByStatus :-
        clients(CLName, CLNum, CLStatus),
        ByStatus = [ clients(CLName, CLNum, CLStatus) || clients(CLName, CLNum, CLStatus) ].

    sum_price() = Sum :-
        Sum = sum([ Price || goods(_, _, Price, _, _) ]).

    max_price() = Res :-
        max([ Price || goods(_, _, Price, _, _) ], Max),
        Res = Max,
        !.

    min_price() = Res :-
        min([ Price || goods(_, _, Price, _, _) ], Min),
        Res = Min,
        !.

% Правило. Товар и его статус запрета.
    prodphob(X) :-
        goods(_, X, _, PType, PProhibition),
        write("Название товара: [", X, "] | Категория: [", PType, "]"),
        nl,
        write("Статус запрета Аннунаками: [", PProhibition, "]"),
        nl,
        nl,
        fail.
    prodphob(X) :-
        goods(_, X, _, _, _),
        write("\n"),
        nl,
        fail.

% Правило. страна и статус доставки.
    shipment_list(X) :-
        shipment(X, DStatus),
        write("Страна: [", X, "] | Статус доставки: [", DStatus, "]"),
        nl,
        fail.
    shipment_list(X) :-
        shipment(X, _),
        write("\n"),
        nl,
        fail.

% Правило. Сумма продаж за день.
    sum_purchase_date(X) :-
        purchase(_, X, PiD, PAmount),
        goods(PiD, _, PCost, _, _),
        s(Sum),
        С = PAmount * PCost,
        assert(s(Sum + С)),
        fail.
    sum_purchase_date(X) :-
        purchase(_, X, _PiD, _PAmount),
        s(Sum),
        write("Сумма продаж за [", X, "] составляет: ", Sum, " шекелей"),
        nl,
        fail.

% Правило. Статус клиентов.
    clients_by_status(X) :-
        clients(CLName, _, X),
        write("Статус клиента ", CLName, " - [", X, "]"),
        nl,
        fail.

% Правило. Сумма, потраченная клиентом.
    customer_expenses(X) :-
        clients(X, CNum, _),
        purchase(CNum, _, PiD, PAmount),
        goods(PiD, _, PCost, _, _),
        s(Sum),
        С = PAmount * PCost,
        assert(s(Sum + С)),
        fail.
    customer_expenses(X) :-
        s(Sum),
        nl,
        write("Сумма, потраченная ", X, " составляет: ", Sum, " шекелей"),
        nl,
        fail.

clauses
    run() :-
        console::init(),
        reconsult("../blackdb.txt", bmarket),
        write("| Товары и их статус запрета: |"),
        nl,
        prodphob("Т-34").

    run() :-
        console::init(),
        reconsult("../blackdb.txt", bmarket),
        write("| Введите страну клиента, чтобы узнать статус доставки: |"),
        nl,
        shipment_list("Китай").

    run() :-
        console::init(),
        reconsult("../blackdb.txt", bmarket),
        write("| Выручка за определенный день: |"),
        nl,
        sum_purchase_date("04.04.2023").

    run() :-
        console::init(),
        reconsult("../blackdb.txt", bmarket),
        write("| Выручка от определенного клиента: |"),
        nl,
        customer_expenses("Ким Чен Ын").

    run() :-
        console::init(),
        reconsult("../blackdb.txt", bmarket),
        nl,
        write("| Статусы клиентов: |"),
        nl,
        write("Введите статус для получения информации о его обладателях: (статусы: vip, regular, loyal)"),
        nl,
        S = read(),
        clients_by_status(S).

    run() :-
        console::init(),
        reconsult("../blackdb.txt", bmarket),
        write("| Вывод VIP клиентов: |"),
        nl,
        ByStatus = by_status(vip),
        data(ByStatus),
        nl,
        fail.

    run() :-
        console::init(),
        reconsult("../blackdb.txt", bmarket),
        write("Общая стоимость всего: ", sum_price()),
        nl,
        write("Максимальная стоимость: ", max_price()),
        nl,
        write("Минимальная стоимость: ", min_price()),
        nl,
        fail.

    run() :-
        succeed.

end implement main

goal
    console::runUtf8(main::run).
