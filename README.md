# Documentation
## Definitions
| Variable name | Description                                                                                                                                        |
|---------------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| `signal`      | EEG signal (`R-by-X` matrix)                                                                                                                          |
| `ampval`      | single amplitude value in signal ("sample" is ambiguous when talking about training)                                                                  |
| `trial`       | part of signal where an event happens (`R-by-L` matrix)                                                                                               |
| `trials`      | used to describe numerous trials (`R-by-L-by-N` matrix)                                                                                               |
| `trainal`     | selected ampvals of trial, reshaped to vector (`1-by-T*R`) or (`1-by-L`) (in literature often called "sample", but is ambiguous, s.a.)                |
| `trainals`    | used to describe numerous trainals (`N-by-T*R`) or (`N-by-L`)                                                                                         |
| `classes`     | (not only the class descriptions, but) used to describe a cell array {`t_1`, `t_2`, ...} consisting of the trials/trainals for class 1, class 2, etc. |
| `latency`     | start (ampval index in the signal) of a trial                                                                                                         |
| `frame`       | latency and length (in ampvals) of a trial in the signal                                                                                              |

## one-char variable name abbreviations typically used:
| Variable name | Description                                              |
|---------------|----------------------------------------------------------|
| `C`           | number of classes                                        |
| `R`           | number of channels                                       |
| `T`           | number of ampvals in WOI                                 |
| `L`           | number of ampvals in trial/trainal                       |
| `N`           | number of trials/trainals                                |
| `D`           | number of features/ampvals (when talking about training) |

# files names
## eeglab_datasets
| filename   | description                                                           |
|------------|-----------------------------------------------------------------------|
| `_ica.set` | after running ICA algo on data, before removing components            |
| `_rmc.set` | after removing independent components, before finishing preprocessing |
| `.mat.set` | after finishing preprocessing                                         |
