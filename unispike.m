%Unified spike (and LFP) loading tools
%
%Available MATLAB Functions - OK TO USE
% p2mLoad2    - extended version of p2mLoad() that handles "composite" files
% p2muni      - automatically load LFP & spike data from TDT or PLX
%               dependson p2mplx() and p2mtdt() to extract data
% p2mS2       - automatically load companion Spike2 datafile
%               (note: 's2' files are not the same as 'uni' files)
% pca_snips   - do PCA-based cluster plot of spike waveforms
% unimerge    - merge number uni datasets into a single structure (also
%               does the work of p2mMerge at the same time).
% uniinfo     - show and plot summary data from uni/p2mLoad2
%               (uniinfo replaces show_snips() and show_lfps())
% uniselect   - select a sorted spike snip for subsequent analysis
%               (this maps the specified channel/sortcode into the spike_time
%               vector for the pf struct, so all subsequent commands will
%               use the specified sorted channel).
% p2mSubset   - select a subset of trials from a pf structure
%
%Private Functions - NOT RECOMMENDED FOR GENERAL USE
% p2mplx       - load raw .PLX file into standardized unispike data structs
% p2mtdt       - load TDT DataTank to standard unispike structs
% plxloader    - high speed .PLX -> matrix converter
% p2mplx_lfps  - convert raw LFPs from plxloader to standardized format
% p2mplx_snips - convert raw snips from plxloader to standardized format
% tdt*         - raw access to tdt data tanks
% icode        - convert between string/int codes for tdt Tank Stream IDs
%
%Some handy shell scripts/commands are also provided by this toolbox:
% p2muni       - generate uni file for specified p2m file
% auto-plx-uni - generate .uni files for all .plx files in the PlexonData dir
%
