# Managing git repositories

The only interface you have to interact with this **git server** is the SSH interactive console. You
need to use it in order to manage your existing repos.

In order to do so, you just need to **SSH** into this server by running `ssh git@${SERVER_URL}`

You will be prompted on a interactive shell. That is the only interface you have with the server.

The available commands will be displayed to you right away, or you can simply type `help` to view
them.

## Tips

### Hidden repos

If you want to create a hidden repository (not visible through this web interface), you can name
your repository with a leading dot (e.g. _`.myrepo`_)

They are still accessible through SSH via git clones, as well as the _SSH interface_ and you can
view them by using the command `ls`.

### Changing a repo's description or default branch

To change a repo's description or its default branch, you need to connect to the **SSH** interface
and then run the command `config`.
