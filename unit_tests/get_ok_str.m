function [str] = get_ok_str(bool)
    ok_str = {'[FAIL]', '[OK]'};
    str = ok_str{int32(bool) + 1};
end

