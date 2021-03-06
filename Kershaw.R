library(dplyr)
library(data.table)
library(lubridate)

# Reading in the data
pitchfx = as.data.frame(fread("Pitchfx.csv"))

# Converting game_date to a date
pitchfx = pitchfx %>%
  mutate(game_date = dmy(game_date))

# tabling the occurences of pitches
#as.data.frame(table(pitchfx$pitch_type))

# Creating a new categorical variable for runners on base
pitchfx = pitchfx %>%
  mutate(runners = paste0( ifelse(is.na(Runneron1st_ID) == FALSE, 1, 0 ),
                           ifelse(is.na(Runneron2nd_ID) == FALSE, 1, 0 ),
                           ifelse(is.na(Runneron3rd_ID) == FALSE, 1, 0 )) )



# Creating a new categorical variable for count
pitchfx = pitchfx %>%
  mutate(count = paste(pre_balls, pre_strikes, sep = "-"))

# Combining low-occurence pitches into "Other Category"
#Other = c("", "AB", "FO", "IN", "PO", "SC", "UN", "EP")
#Fastballs = c("FC", "FF", "FT", "FA")
#pitchfx = pitchfx %>%
#  mutate(new_pitch_type = ifelse(pitch_type %in% Other, "Other", 
#                                 ifelse(pitch_type %in% Fastballs,"FB", pitch_type)))

# tabling the occurences of pitches after pitch_type update
# as.data.frame(table(pitchfx$new_pitch_type))

# Reading in data to get names from
pitching_stats = read.csv("Pitching_Statistics.csv", header=TRUE)

# Getting unique pitchers names
pitchers = pitching_stats %>%
  distinct(pitcher_id, Name) %>%
  select(pitcher_id, Name)

# Joining with pitchfx data to attach names
pitchfx = left_join(pitchfx, pitchers)

###################### ALL PITCHERS #################################
pitchfx = pitchfx %>%
  arrange(game_date, at_bat_number)

# Removing intentional balls and combining some pitch types
#Other = c("CH", "CU")
pitchfx = pitchfx %>%
  filter(pitch_type != "IN") # %>%
  #mutate(new_pitch_type = ifelse(pitch_type %in% Other, "CH or CU", pitch_type))



# Turning variables that are supposed to be factors into factors
pitchfx = pitchfx %>%
  mutate(pre_outs = as.factor(pre_outs),
         pre_strikes = as.factor(pre_strikes),
         pre_balls = as.factor(pre_balls),
         count = as.factor(count),
         runners = as.factor(runners),
         top_inning_sw = as.factor(top_inning_sw),
         bat_side = as.factor(bat_side),
         inning = as.numeric(inning))


# Just Clayton Kershaw's pitches
kershaw = pitchfx %>%
  filter(Name == "Kershaw, Clayton") 

runners_count = rep(0, nrow(kershaw))

for (i in 1:nrow(kershaw)){
  
  if (is.na(kershaw$Runneron1st_ID[i]) == FALSE){
    runners_count[i] = runners_count[i] + 1
  }
  
  if (is.na(kershaw$Runneron2nd_ID[i]) == FALSE){
    runners_count[i] = runners_count[i] + 1
  }
  
  if (is.na(kershaw$Runneron1st_ID[i]) == FALSE){
    runners_count[i] = runners_count[i] + 1
  } 
  
}

kershaw = kershaw %>%
  mutate(runners_count = runners_count)

# Creating a new variable for the pitch number of the game
pitchcounts = c()
pitchcounts[1] = 1
for(i in 2:nrow(kershaw))
{
  if(kershaw$game_id[i] == kershaw$game_id[i-1])
  {
    pitchcounts[i] = pitchcounts[i-1] + 1
  } else
  {
    pitchcounts[i] = 1
  }
}

kershaw = kershaw %>%
  mutate(pitch_count = pitchcounts)

# Creating a new variable for the previous pitch type
previous_pitch_type = c()
previous_pitch_type[1] = "FF"
for(i in 2:nrow(kershaw))
{
  previous_pitch_type[i] = kershaw$pitch_type[i-1]
}

kershaw = kershaw %>%
  mutate(prev_pitch_type = previous_pitch_type)

# Creating a new variable for the previous event type
previous_event_type = c()
previous_event_type[1] = "FF"
for(i in 2:nrow(kershaw))
{
  previous_event_type[i] = kershaw$event_type[i-1]
}

kershaw = kershaw %>%
  mutate(previous_event_type = previous_event_type)

runners_count = rep(0, nrow(kershaw))

for (i in 1:nrow(kershaw)){

  if (is.na(kershaw$Runneron1st_ID[i]) == FALSE){
    runners_count[i] = runners_count[i] + 1
  }
  
  if (is.na(kershaw$Runneron2nd_ID[i]) == FALSE){
    runners_count[i] = runners_count[i] + 1
  }

  if (is.na(kershaw$Runneron1st_ID[i]) == FALSE){
    runners_count[i] = runners_count[i] + 1
  } 

}

kershaw = kershaw %>%
  mutate(runners_count = runners_count)

# Removing intentional balls and combining some pitch types
Other = c("CH", "CU")
kershaw = kershaw %>%
  filter(pitch_type != "IN") %>%
  mutate(new_pitch_type = ifelse(pitch_type %in% Other, "CH or CU", pitch_type))

# Creating a new variable for the pitch number of the game
pitchcounts = c()
pitchcounts[1] = 1
for(i in 2:nrow(kershaw))
{
  if(kershaw$game_id[i] == kershaw$game_id[i-1])
  {
    pitchcounts[i] = pitchcounts[i-1] + 1
  } else
  {
    pitchcounts[i] = 1
  }
}

kershaw = kershaw %>%
  mutate(pitch_count = pitchcounts)

# Creating a new variable for the previous pitch type
previous_pitch_type = c()
previous_pitch_type[1] = "FF"
for(i in 2:nrow(kershaw))
{
  previous_pitch_type[i] = kershaw$pitch_type[i-1]
}

kershaw = kershaw %>%
  mutate(prev_pitch_type = previous_pitch_type)

# Creating a new variable for the previous event type
previous_event_type = c()
previous_event_type[1] = "FF"
for(i in 2:nrow(kershaw))
{
  previous_event_type[i] = kershaw$event_type[i-1]
}

kershaw = kershaw %>%
  mutate(previous_event_type = previous_event_type)

# Turning variables that are supposed to be factors into factors
kershaw = kershaw %>%
  mutate(pre_outs = as.factor(pre_outs),
         pre_strikes = as.factor(pre_strikes),
         pre_balls = as.factor(pre_balls),
         count = as.factor(count),
         runners = as.factor(runners),
         top_inning_sw = as.factor(top_inning_sw),
         bat_side = as.factor(bat_side),
         previous_pitch_type = as.factor(previous_pitch_type),
         inning = as.numeric(inning),
         runners_count = as.factor(runners_count))

# Removing any pitches thrown after the 102nd pitch because 
# these pitches are not representative of his average start
# kershaw = kershaw %>%
  # filter(pitch_count <= 102)


