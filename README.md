# Eurovision_PLS
Code and variables for the "What makes a Eurovision song Eurovision-y" project (background info here: https://twitter.com/sciencebanshee/status/1396157641466974214).

The code is in "Eurovision_PLS.m" and all the necessary variables are in "Eurovision_WS.mat". The variable file contents are as follows:
  Arousal: Arousal extracted from the song files using MIR Toolbox (code in "Eurovision_MIR.m")
  Arousal_R: Arousal variables in song order
  Valence: Valence extracted from song files using MIR Toolbox
  Valence_R: Valence variables in song order
  Concensus: song data and average scores on survey items (songs are rows (n = 21), features are columns (n = 20))
  Concensus_Labs: labels for the concensus matrix (columns)
  evres: the PLS results
  Feature_Labels: Valence and Arousal fature labels
  Labels: song labels
  Music_Labs: MIR variable labels
  option: PLS running options
