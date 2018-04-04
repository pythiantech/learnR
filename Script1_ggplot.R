#Script 1

#Data Visualization with ggplot

library(tidyverse)
library(ggplot2)


#Do cars with big engines use more fuel than cars with small engines? 
#?mpg
str(mpg)

#Your first plot
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))

#This is the basic template 
# ggplot(data = <DATA>) +
#   <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>))

#Aesthetic Mappings
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = class))


ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, size = class))

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, alpha = class))

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, shape = class))

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), colour = "red")


#Facets;split your plot into facets, subplots that each display one subset of the data
#To facet your plot by a single variable, use facet_wrap(). The first argument of facet_wrap() 
#should be a formula, which you create with ~ followed by a variable name 
#(here “formula” is the name of a data structure in R, not a synonym for “equation”). 
#The variable that you pass to facet_wrap() should be discrete.

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_wrap(~ cyl, nrow = 3)


#To facet your plot on the combination of two variables, add facet_grid() to your plot call.
#The first argument of facet_grid() is also a formula. This time the formula should contain 
#two variable names separated by a ~.

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_grid(drv ~ cyl)


#Geometric Objects
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))

ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy))

#Different geoms have different aesthetics

ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy, linetype = drv))

ggplot(data = mpg) + 
  geom_point(aes(x=displ, y=hwy, colour=drv))+
  geom_smooth(mapping = aes(x = displ, y = hwy, linetype = drv))

#you can set the group aesthetic to a categorical variable to draw multiple objects
ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy))

ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy, group = drv))

ggplot(data = mpg) +
  geom_smooth(
    mapping = aes(x = displ, y = hwy, color = drv),
    show.legend = FALSE
  )

#Global Mappings
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_smooth()

#If you place mappings in a geom function, ggplot2 will treat them as local mappings for the layer. 
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(color = class)) + 
  geom_smooth()

#specify different data for each layer
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(color = class)) + 
  geom_smooth(data = filter(mpg, class == "subcompact"), se = FALSE)



##########################
#Statistical Transformations
#?diamonds

ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut))
#Bar charts calculate new values to plot!

#You can generally use geoms and stats interchangeably.
ggplot(data = diamonds) + 
  stat_count(mapping = aes(x = cut))

#Plor proportions
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, y = ..prop.., group=1))

#https://stackoverflow.com/questions/39878813/r-ggplot-geom-bar-meaning-of-aesgroup-1/39879232
#To understand group

#You might want to draw greater attention to the statistical transformation in your code. 
#For example, you might use stat_summary(), which summarises the y values for each unique 
#x value, to draw attention to the summary that you’re computing:

ggplot(data = diamonds) + 
  stat_summary(
    mapping = aes(x = cut, y = depth),
    fun.ymin = min,
    fun.ymax = max,
    fun.y = median
  )



#Position Adjustments
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, colour = cut))
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = cut))

ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity))

#If you don’t want a stacked bar chart, you can use one of three other 
#options: "identity", "dodge" or "fill"


#position = "identity" will place each object exactly where it falls in the context of the graph. 
#This is not very useful for bars, because it overlaps them. To see that overlapping we either 
#need to make the bars slightly transparent by setting alpha to a small value, or completely 
#transparent by setting fill = NA.
ggplot(data = diamonds, mapping = aes(x = cut, fill = clarity)) + 
  geom_bar(alpha = 1/5, position = "identity")

ggplot(data = diamonds, mapping = aes(x = cut, colour = clarity)) + 
  geom_bar(fill = NA, position = "identity")


#position = "fill" works like stacking, but makes each set of stacked bars the same height.
#This makes it easier to compare proportions across groups.

ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "fill")


#position = "dodge" places overlapping objects directly beside one another. This makes 
#it easier to compare individual values.

ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "dodge")


#You can avoid this gridding by setting the position adjustment to “jitter”. 
#position = "jitter"
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), position = "jitter")

#it makes your graph less accurate at small scales, it makes your graph more revealing at large scales

#Coordinate Systems
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) + 
  geom_boxplot()
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) + 
  geom_boxplot() +
  coord_flip()


#coord_quickmap() sets the aspect ratio correctly for maps. This is very important if 
#you’re plotting spatial data with ggplot2 
nz <- map_data("nz")

ggplot(nz, aes(long, lat, group = group)) +
  geom_polygon(fill = "white", colour = "black")

ggplot(nz, aes(long, lat, group = group)) +
  geom_polygon(fill = "white", colour = "black") +
  coord_quickmap()

#coord_polar() uses polar coordinates. Polar coordinates reveal an interesting connection 
#between a bar chart and a Coxcomb chart.

bar <- ggplot(data = diamonds) + 
  geom_bar(
    mapping = aes(x = cut, fill = cut), 
    show.legend = FALSE,
    width = 1
  ) + 
  theme(aspect.ratio = 1) +
  labs(x = NULL, y = NULL)

bar + coord_flip()
bar + coord_polar()
