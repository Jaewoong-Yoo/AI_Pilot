:START
taskkill /f /im DCS.exe
@REM C:\Users\Jaewoong\anaconda3\envs\condaRL\python E:\DCS_project\DCSIntegrated.py --best_model True --last_n_epi True --logging_wandb True --random_action True
C:\Users\Jaewoong\anaconda3\envs\condaRL\python E:\DCS_project\DCSIntegrated.py --best_model True --last_n_epi True --log_wandb True --accelerate_sim True
timeout 10 > NUL
@GOTO START
@REM Exit