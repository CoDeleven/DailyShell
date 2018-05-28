由于hexo的源文件需要自己额外保存，我每次都需要push 原md文件，再将原文件全复制到hexo的_posts文件里

由于hexo的源文件需要自己额外保存到github上，所以我专门建了一个文件夹用来存放md文件，然而每次重复的工作让我头皮发麻，而且不好管理：

`创建md文件 -> commit 并推送到 远程仓库 -> 复制修改过的md文件到hexo的_posts目录里 -> hexo c -> hexo g -> hexo d`

这个脚本就是我用来拯救自己的工具：

`创建md文件 -> commit 并推送到 远程仓库 -> 执行uploader`

因为commit里的消息还是很重要的，我选择自己手动推送，最后的步骤交给uploader


----------------------------
谢谢使用

欢迎各位提出意见 :)

作者：Codeleven
github：https://github.com/CoDeleven/DailyShell
如果喜欢这个脚本，或者想提出更好的方案，请pull request
如果您有任何问题或建议请您及时和我联系：codelevex@gmail.com
