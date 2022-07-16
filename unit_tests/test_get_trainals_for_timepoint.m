R = 10;%           R...number of channels
L = 20;%           L...number of ampvals per trial
N = 10;%           N...number of trials

trials = rand(R, L, N, 'single');
t_indices = 0:3:10;

ok = false(R, N, 3);
for t=1:3
    trainals = get_trainals_for_timepoint(trials, t_indices, t); %N-by-T*R
    for n=1:N
        for r=1:R
            ok(r, n, t) = all(trainals(n, (r-1)*length(t_indices)+1:r*length(t_indices)) == trials(r, t+t_indices, n));
        end
    end
end
fprintf(['get_trainals_for_timepoint: ' get_ok_str(all(ok, 'all')) '\n']);
