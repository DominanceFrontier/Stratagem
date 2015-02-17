import pygame, random, math

pygame.init()

#------------------------------------------------------------------------------
# COLORS
#------------------------------------------------------------------------------
BLACK = (0, 0, 0)
RED = (255, 0, 0)
GREEN = (0, 255, 0)
BLUE = (0, 0, 255)
WHITE = (255, 255, 255)

#------------------------------------------------------------------------------
# SCREEN
#------------------------------------------------------------------------------
screen_width = 640
screen_height = 480
screen_size = (screen_width, screen_height)
display = pygame.display
screen = display.set_mode(screen_size)
display.set_caption("A Random Maze Generation Demonstration.")

#------------------------------------------------------------------------------
# Clock
#------------------------------------------------------------------------------
clock = pygame.time.Clock()

#------------------------------------------------------------------------------
# Display Loop
#------------------------------------------------------------------------------
user_has_not_quit = True 

while user_has_not_quit:

    # Process events
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            user_has_not_quit = False

    # Clear screen
    screen.fill(WHITE)

    # Draw to screen
    pygame.draw.rect(screen, RED, (55, 23, 142, 123))
    pygame.draw.line(screen, GREEN, (60, 100), (200, 300))
    
    # Flip screen
    display.flip()
    
    # Limit fps to 60
    clock.tick(60)


print math.pi

pygame.quit()
