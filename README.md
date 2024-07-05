# My Linux environment

 Some configuration files for my Linux environment (.vimrc, bashrc, ...).

## Bashrc aliases, functions and others

You can include the my-home-env.bashrc content in you ~/.bashrc file:

```bash
# Open your home .bashrc file
$ vim ~/.bashrc

# Add the following line in the file
source /path/to/the/file/my-home-env.bashrc

# Save and close the file

# Source your ~/.bashrc file to immedialty appy the changes
source ~/.bashrc
```

Example on my laptop:

```bash
# Open your home .bashrc file (example with vim)
$ vim ~/.bashrc

# Add the following line in the file
source ~/git/my-linux-env/my-home-env.bashrc

# Save and close the file

# Source your ~/.bashrc file to immedialty appy the changes
source ~/.bashrc
```

My favorite functions: `ossl`, `cssl` and `proto`

## .vimrc

You can include the `vimrc` file in your ~/.vimrc file or you can use a symbolik link pointing to it (in this case you probably need to move you current ~/.vimrc if exists):

```bash
# If exists, move your old ~/.vimrc file
$ mv ~/.vimrc ~/.vimrc.old

# Create a symbolik link ~/.vimrc -> /path/to/the/file/vimrc 
$ ln -s /path/to/the/file/vimrc ~/.vimrc
```

Example on my laptop:

```bash
# If exists, move your old ~/.vimrc file
$ mv ~/.vimrc ~/.vimrc.old

# Create a symbolik link ~/.vimrc -> ~/git/my-linux-env/vimrc ~/.vimrc
$ ln -s ~/git/my-linux-env/vimrc ~/.vimrc
```

## Contributing

If you want to add more content or fix some mistake, you are free to fork this repo and create a Pull Request.
