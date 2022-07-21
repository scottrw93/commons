# Thread dump scripts.

Both scripts need to be in the same path. Example of usage:
```
bash k8s_run_and_get_jstacks.sh app-blazarbuildscheduler-service deployment-mainline-7c96455c85-46f8w
```

These scripts are handy when a thread dump is needed for k8s apps. It will automagically take 3 thread dumps,
archive them and download them. Make sure to use/be authenticated to the correct cluster before invoking the scripts



