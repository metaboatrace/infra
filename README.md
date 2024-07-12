## AWS Systems Manager Parameter Store

AWS Systems Manager (SSM) Parameter Store で本番・ステージング各々のデータベースアカウントを設定する  
パラメータ名は以下とする

- `/staging/database-username`
- `/staging/database-password`
- `/production/database-username`
- `/production/database-password`

パスワードに関しては、種類を "SecureString" にすること
