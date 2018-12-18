# tlarb

Ruby library for Twitcasting Live Analytics

- __Live Stream__  
ライブの情報取得＆データベースに保存するモード。  
基本的に、対象のライブが終了するまでプログラムは走り続ける。  
走らせ続ける方法は２種類(Clockwork実行、loop methodを用いた通常実行)  
(*) Clockwork実行はdeveloper用。  
さらに２種類のモード  
	- __ライブ指定モード__  
	実行者が対象ライブを設定し、そのライブの情報取得＆データベースに保存  
	- __おすすめモード__  
	自動でおすすめライブをピックアップし、そのライブの情報取得＆データベースに保存  
- __Live Analytics__  
ライブ分析を行うモード。結果はデータベースに保存。  
	- __Active Analytics__  
		- __Active Comment Count (アクティブコメント数)__  
		ライブ中のコメント件数のアクティブ推移  
		- __Active User Count (同時視聴者数)__  
		ライブ中の同時視聴者数  
	- __Others__  
		- __Total Comment Count (総コメント数)__  
		ライブ開始からの合計コメント件数  
		- __Max Viewer Count (最大同時視聴数)__  
		ライブ中の最大同時閲覧者数  
		- __Total Viewer Count (総視聴者数)__  
		ライブ開始からの合計閲覧者数  
		- __User Comment Rank(ユーザー別コメント件数)__  
		ライブ開始から終了の間にコメント件数の多いユーザー集計  
		- __頻出単語__  
		- __感情分析__  
- __Viewer__  
データベース(ライブ分析結果)を読んでユーザーに所望のデータを提供  
Format is as below.  
	- __image file (.png)__  
	- __text file (.txt)__  
- __CommentViewer__  
Viewerモードの特殊版（StreamモードとViewerモードの組み合わせ）。  
ライブ指定モードで通常実行(loop method)し、データベース(comment viewer用temporally DB)に保存しつつ、ターミナル上にコメント表示  

## Installation

```rb
under construction
```

## Preparation before using

Before using tlarb, we need to get access token in order to access TwitCasting API (APIv2).
Because this library internally access to the API.
Please refer to README of [twicas_stream](https://github.com/ysato5654/twicas_stream)

## Usage

### 'Live Stream' mode

- by movie id

```rb
ruby live_stream.rb -m 189037369
```

- by user id

```rb
ruby live_stream.rb -u 182224938
```

### pseudo Comment Viewer

Get comments of movie id frequently while live is on.

```rb
# (*) following data are just example

# 1. set access token
TwicasStream.configure do |request_header|
	request_header.access_token = 'xxx'
end

# 2. get movie id via user id
user_id = 'twitcasting_jp'
api_user = TwicasStream::User::GetUserInfo.new(user_id)
user_info = api_user.response[:user]

movie_id = user_info[:last_movie_id]
limit = 10
slice_id = 'none'

loop do
	# 3. check live status
	api_movie = TwicasStream::Movie::GetMovieInfo.new(movie_id)
	break unless api_movie.response[:movie][:is_live]

	# 4. get comments
	api_comment = TwicasStream::Comment::GetComments.new(movie_id = movie_id, limit = limit, slice_id = slice_id)
	comments = api_comment.response[:comments]

	p '--------------------------------'
	comments.each{ |comment|
		p comment[:from_user][:name] + ' ' + '(' + '@' + comment[:from_user][:screen_id] + ')'
		p comment[:message]
		p Time.at(comment[:created])
		p '--------------------------------'
	}

  # 5. repeat 3 ~ 4 until end of live
end
```

## DB (Data Base)

### Directory structure

```
/db									  
└─	/#{year}						  
	└─	/#{month}					  
		└─	/#{day}					  
			└─	#{movie_id}.sqlite3	  
```

### Data base association

![Data base association](images/data_base_association.png)

---

## Development

Here is for developer

### Preparation before developing

Before develop twicas_stream, we need to prepare as below.
Because example srouce code and test code need access

1. Create '/config' directory
2. Create 'access_token.txt' in there
3. Write your access token in that file

### tlarb

```rb
module Tlarb
	module Model
		class MovieInfo < ActiveRecord::Base
		end

		class CommentList < ActiveRecord::Base
		end

		class User < ActiveRecord::Base
		end

		class Movie < ActiveRecord::Base
		end

		class Comment < ActiveRecord::Base
		end
	end

	class Stream
	end

	class Analytics
	end

	class ActiveCommentCount < Analytics
	end

	class ActiveUserCount < Analytics
	end

	class TotalCommentCount < Analytics
	end

	class MaxViewerCount < Analytics
	end

	class TotalViewerCount < Analytics
	end

	class UserCommentRank < Analytics
	end

	class View
	end

	class Gnuplot < View
	end
end
```

### Directory structure

```
/										  
├─	/analysis							  
├─	/app								  
│	└─	live_stream.rb					  
├─	/bin								  
├─	/config								  
│	├─	access_token.txt				  
│	└─	database.yml					  
├─	/db									  
├─	/lib								  
│	├─	/tlarb							  
│	│	├─	stream.rb					  
│	│	├─	analytics.rb				  
│	│	├─	models						  
│	│	│	├─	movie_info.rb			  
│	│	│	├─	comment_list.rb			  
│	│	│	├─	user.rb					  
│	│	│	├─	movie.rb				  
│	│	│	└─	comment.rb				  
│	│	├─	model.rb					  
│	│	├─	view.rb						  
│	│	├─	configure.rb				  
│	│	└─	version.rb					  
│	└─	tlarb.rb						  
├─	/log								  
├─	/spec								  
│	├─	/tlarb							  
│	└─	spec_helper.rb					  
│	└─	tlarb_spec.rb					  
├─	LICENSE								  
└─	README.md							  
```

