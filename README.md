# Meta Boatrace Infra

## 概要

[Meta Boatrace](https://github.com/metaboatrace/docs) のインフラリソースを一元的に IaC で管理するためのリポジトリ

## 必要なバージョン

- **AWS CLI**: v2.0.0 以上
- **Terraform**: v1.8.0 以上
- **AWS Provider for Terraform**: v5.40 以上

## AWS CLI のインストール

```bash
$ brew install awscli
```

## AWS CLI でのプロファイル設定

```bash
$ aws configure --profile <profile-name>
```

もしくは

```bash
export AWS_PROFILE=<profile-name>
```

`<profile-name>` は適宜置き換えること  
プロファイルにはIAMの生成権限が必要

## Terraform のインストール

複数バージョンの管理を容易にするために、`tfenv` の使用を推奨

```bash
$ brew install tfenv
$ tfenv install 1.8.5
$ tfenv use 1.8.5
$ terraform -version
Terraform v1.8.5
on darwin_arm64
```

## AWS Systems Manager Parameter Store

AWS Systems Manager (SSM) Parameter Store で本番・ステージング各々のデータベースアカウントを設定する  
パラメータ名は以下とする

- `/metaboatrace/origin-data/staging/db/username`
- `/metaboatrace/origin-data/staging/db/password`
- `/metaboatrace/origin-data/production/db/username`
- `/metaboatrace/origin-data/production/db/password`

以下のコマンドで設定できる

```bash
$ aws ssm put-parameter --name "/metaboatrace/origin-data/staging/db/username" --value "root" --type "String"
$ aws ssm put-parameter --name "/metaboatrace/origin-data/staging/db/password" --value <your_staging_db_password> --type "SecureString"
$ aws ssm put-parameter --name "/metaboatrace/origin-data/production/db/username" --value "root" --type "String"
$ aws ssm put-parameter --name "/metaboatrace/origin-data/production/db/password" --value <your_production_db_password> --type "SecureString"
```

`<your_staging_db_password>` と `<your_production_db_password>` は適宜置き換えること  
必要に応じてユーザーも最小権限のものを生成することを推奨

## Terraform によるインフラリソースの生成

ルートモジュールは `environments/` ディレクトリ以下にある  
これらのサブディレクトリから、インフラリソースを生成したい環境を選択する

例えば、ステージング環境で実行するなら以下

```bash
$ cd environments/staging
$ terraform init
$ terraform apply
```

## （任意） コード整形とバリデーションの自動実行

このリポジトリでは、コミットの前にコード品質チェックを自動で行うための [pre-commit](https://pre-commit.com/) をサポートしている

これを利用する場合は以下の手順で有効化できる

### 前提条件

**Python**: `pre-commit` には Python の環境が必要

### pre-commit のインストール

```bash
$ pip install pre-commit
```

### pre-commit のセットアップ

```bash
$ pre-commit install
```

このコマンドは、`.pre-commit-config.yaml` ファイルで指定されたプレコミットフックをインストールする

### pre-commit の実行

すべてのファイルに対して `pre-commit` フックを手動で実行するには、以下を実行する

```bash
$ pre-commit run --all-files
```

## pre-commit のアップデート

```bash
$ pre-commit autoupdate
```

## pre-commit の自動実行をスキップ

`pre-commit` は、変更をコミットするときに自動的に実行される  
自動実行したくない場合は以下のように `--no-verify` オプションで迂回できる

```bash
$ git commit --no-verify
```
