function gfp = GFP(ampvals)
%GFP Global Field Power.
%   Calculate the global field power (GFP) of given amplitude values.
%
%   gfp = GFP(ampvals) returns the global field power for each timepoint.
%       ampvals: N-Dimensional matrix with channels as rows, so
%           size(ampvals, 1) is the number of channels
%       gfp: N-Dimensional matrix with size(gfp, 1) being 1. contains the
%           GFP for each input dimension.

    N = length(size(ampvals));  % dimensionality of input matrix
    n = size(ampvals, 1);  % number of channels

    % formula 1A in lehmann1980: RMS (reference-free):
    % GFP = sqrt( 1/(2n) * sum_i=1^n sum_j=1^n (u_i - u_j)^2 )
    addmat = permute(ampvals, [N+1 1 2:N]);
    submat = permute(ampvals, [1 N+1 2:N]);
    gfp = sqrt(1/(2*n) * permute(...
            sum((addmat - submat).^2, [1 2]), ...
         [2:N+1 1])...
    );
    % permute magic:
    % 1. for additive matrix:
    %    bring new empty dimension (N+1) to first dimension
    %    bring first dimension to second
    %    shift the remaining dimensions one up
    % 2. for subtractive matrix:
    %    bring new empty dimension (N+1) to second dimension
    %    leave first dimension
    %    shift the remaining dimensions one up
    % (We now have two matrices which are just a row resp. column vector in
    % the first two dimensions.)
    % 3. when subtracting the two matrices we get an N+1-dimensional matrix
    %    which has the difference of all pairs of amplitude values stored
    %    as a page. The index of each page is one above the corresponding
    %    input dimension.
    % 4. Square the differences (see formula) (dimensions stay the same).
    % 5. We then sum the first and second dimension up, which correspond to
    %    the amplitude differences.
    % (We now have a matrix which is just a scalar in the first two
    % dimensions, the remaining dimensions are still shifted one up.)
    % 6. To unshift the dimensions:
    %    shift second to last dimension one down. they now correspond to
    %    the original dimensions.
    %    bring (empty) first dimension to last
    % The result is again N-dimensional, but the first dimension is of size
    % 0, since it corresponds to the channels, which are mapped to a scalar
    % by the GFP function.
end
