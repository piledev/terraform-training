# terraform-training

Terraform を初めて触ったときの手順を整理しています。

## 1. Terraform のインストール

1. anyenv のインストール
1. tfenv のインストール

## 2. Terraform 用の service account 作成

- サービスアカウントの作成

```sh
gcloud iam service-accounts create terraform --display-name "Terraform"
```

- サービスアカウントに Editor ロールを付与

```sh
gcloud projects add-iam-policy-binding [PROJECTNAME] \
--member serviceAccount:terraform@[PROJECTNAME].iam.gserviceaccount.com \
--role roles/editor
```

- JSON キーの作成とダウンロード

```sh
gcloud iam service-accounts keys create terraform_serviceaccount_credential.json \
--iam-account=terraform@[PROJECTNAME].iam.gserviceaccount.com
# -> 今回はこの README.md と同じディレクトリで実行する
# -> 実行したディレクトリにjsonファイルが生成される
```

## 3. tfstate ファイル保存用 GCS バケット作成

- terraform-state-bucket_lifecycle.json を作成する

  - 直近 5 バージョンを保持する設定

- `gsutil`でバケットを作成する

```sh
gsutil mb -p [PROJECTNAME] -c STANDARD -l us-central1 -b on gs://[BUCKETNAME]/
gsutil versioning set on gs://[BUCKETNAME]/
gsutil lifecycle set terraform-state-bucket_lifecycle.json gs://[BUCKETNAME]/
```

## 4. Terraform の設定

- main.tf の作成

  - 認証情報と操作対象のプロジェクトを指定するのみ。
  - この時点では terraform-lsp から`[TerraformeSchema]_[E] Provider google does not exist` と怒られるが気にしない。
    - 後述の terraform init のタイミングで解消される。
  - 書いたら main.tf と同じディレクトリで以下を実行するように。

    ```sh
    terraform fmt      # format
    terraform validate # validate

    ```

## 5. Terraform の初期化

```sh
# main.tf のあるディレクトリで実行
terraform init
```

- terraform の初期化処理
- .terraform ディレクトリが作成されて、その中でバージョンロックしたり tfstate 持ったりする
- その他必要なプラグインのインストールもここで行われる
- provider plugin(今回の場合 google)がインストールされるのもここ
- main.tf があるディレクトリで実行しないといけないのがキモ
  - まあ、間違えてもエラーメッセージで教えてくれるからすぐわかるんだけど

## 6. プランの確認

```sh
# main.tf のあるディレクトリで実行
terraform plan
```

## 7. インフラの変更

```sh
# main.tf のあるディレクトリで実行
terraform apply
```

## 8. インフラの削除

```sh
# main.tf のあるディレクトリで実行
terraform destroy
```

# 参考

[HashiCorpLearn](https://learn.hashicorp.com/tutorials/terraform/google-cloud-platform-build?in=terraform/gcp-get-started)
