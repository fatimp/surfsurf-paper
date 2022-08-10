module ExecTimes

function do_shit_2d(fn, range)
    map(range) do side
        array = rand(Bool, (side, side))
        t1 = time_ns()
        fn(array, false; periodic = true) |> size |> println
        t2 = time_ns()
        (side, (t2 - t1)/10.0^9)
    end
end

function do_shit_3d(fn, range)
    map(range) do side
        array = rand(Bool, (side, side, side))
        t1 = time_ns()
        fn(array, false; periodic = true) |> size |> println
        t2 = time_ns()
        (side, (t2 - t1)/10.0^9)
    end
end

end
