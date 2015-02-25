class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.all
    @refresh_flag = 0
    @release_class = ''
    @title_class = ''

# if the array of checked items has contents, then find all movies that
# match the parameters in them
    if(@selected_ratings != nil)
      @movies = @movies.find_all{ |film| @selected_ratings.has_key?(film.rating) and @selected_ratings[film.rating]==true}
    end
#SORT MOVIES
# check to see if we are being told to sort by title, if so store the 
# sort params in session data and sort the @movies member, elsif are we
# being told to sort by release, if so store the params in session data
# and sort @movies accordingly, elsif check to see if the session hash has
# data in it, if so load that data into the params and reload the page to
# apply the sort
    if(params[:sort].to_s == 'title')
      session[:sort] = params[:sort]
      @title_class = 'hilite'
      @release_class = ''
      @movies = @movies.sort_by{|film| film.title.to_s}
    elsif(params[:sort].to_s == 'release')
      session[:sort] = params[:sort]
      @release_class = 'hilite'
      @title_class = ''
      @movies = @movies.sort_by{|film| film.release_date.to_s}
    elsif(session.has_key?(:sort))
      params[:sort] = session[:sort]
      @refresh_flag = 1
    end

# FILTER BY RATING
# checks to see if there is any data for ratings in params, if so
# it loads that data into the session and filters @movies to only
# show movies that have the selected ratings, if not it checks the
# session data for ratings data, if present that data is loaded into
# params and the refresh flag is set to ensure the data will be sorted
# appropriately
    if(params[:ratings]!=nil)
      session[:ratings] = params[:ratings]
      @movies = @movies.find_all{ |film| params[:ratings].has_key?(film.rating)}
    elsif(session.has_key?(:ratings))
      params[:ratings] = session[:ratings]
      @refresh_flag = 1
    end

# REFRESH
# if the flag has been set to 1 then the data we needed was in the session
# hash and the page has extracted the data from it and loaded it into
# params, but the page must be reloaded to now sort the data that has been
# loaded into params
    if(@refresh_flag == 1)
      redirect_to movies_path(:sort=>params[:sort], :ratings=>params[:ratings])
    end

    @selected_ratings = {}
    @ratings_list = ['G','PG','PG-13','R','NC-17']

# STORE SELECTED RATINGS
# for each rating, if the rating is in the params, add it to the
# list of selected ratings
    @ratings_list.each do |rating, value|
      if params[:ratings] == nil
        @selected_ratings[rating] = true
      else
        @selected_ratings[rating] = params[:ratings].has_key?(rating)
      end
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
