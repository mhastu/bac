# Single-Trial Classification of EEG data from Gel, Water and Dry Systems
This Repository holds the software part of my bachelor's thesis. It's main target is to continue the work of [Müller-Putz et al., 2020], answering following questions:
- How well can EEG signals be decoded in a cross-participant manner?
  i.e. When training a classificator with single-trial EEG data of 14 different participants, how well does it perform on a 15th, previously unseen, participant?
- How well can EEG signals be decoded in a cross-system manner?
  i.e. When training a classificator with single-trial EEG data of 3 different recording systems with data of 14 participants each, how well does it perform on each 15th, previously unseen, participant?

# Software Documentation
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

## files names
## eeglab_datasets
| filename   | description                                                           |
|------------|-----------------------------------------------------------------------|
| `_ica.set` | after running ICA algo on data, before removing components            |
| `_rmc.set` | after removing independent components, before finishing preprocessing |
| `.mat.set` | after finishing preprocessing                                         |

---
# References
[Müller-Putz et al., 2020] Schwarz, A., Escolano, C., Montesano, L., Müller-Putz, G. (2020). "Analyzing and Decoding Natural Reach-and-Grasp Actions Using Gel, Water and Dry EEG Systems" Frontiers in Neuroscience 14. doi: 10.3389/fnins.2020.00849 
[Blankertz et al., 2011] Blankertz, B., Lemm, S., Treder, M., Haufe, S., and Müller, K.-R. (2011). "Single-trial analysis and classification of ERP components—a tutorial" NeuroImage 56, 814–825. doi: 10.1016/j.neuroimage.2010.06.048
[Schäfer et al., 2005] Schäfer, Juliane and Strimmer, Korbinian. (2005). "A Shrinkage Approach to Large-Scale Covariance Matrix Estimation and Implications for Functional Genomics" Statistical Applications in Genetics and Molecular Biology, vol. 4, no. 1, 2005. https://doi.org/10.2202/1544-6115.1175