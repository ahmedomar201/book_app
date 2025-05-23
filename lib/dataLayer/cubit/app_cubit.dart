import 'package:book_list_app/dataLayer/cubit/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/constansts.dart';
import '../networks/models/book_model.dart';
import '../networks/repository/repository.dart';

AppBloc get cubit => AppBloc.get(navigatorKey.currentContext!);

class AppBloc extends Cubit<AppState> {
  final Repository repo;

  AppBloc({required Repository repository})
    : repo = repository,
      super(Empty()) {
    getBooks();
  }

  static AppBloc get(context) => BlocProvider.of(context);


  TextEditingController nameBookController = TextEditingController();
  BookModel? books;
  int page = 1;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  List<Results> allBooks = [];
  bool isSearching = false;

  void getBooks({bool isPagination = false, context}) async {
    if (isPagination) {
      if (isLoadingMore || !hasMoreData) return;
      isLoadingMore = true;
      emit(GetBooksPaginationLoading());
    } else {
      emit(GetBooksLoading());
      allBooks.clear();
      page = 1;
      hasMoreData = true;
    }

    final result = await repo.getBooks(page);

    result.fold(
      (failure) {
        isLoadingMore = false;
        if (isPagination) {
          emit(GetBooksPaginationError(error: failure));
        } else {
          emit(GetBooksError(error: failure));
        }
      },
      (data) {
        if (data.results != null && data.results!.isNotEmpty) {
          allBooks.addAll(data.results!);
          page++;
        } else {
          hasMoreData = false;
        }

        books = data;
        isLoadingMore = false;

        if (isPagination) {
          emit(GetBooksPaginationSuccess());
        } else {
          emit(GetBooksSuccess());
        }
      },
    );
  }

  void searchBooks({bool isPagination = false, context}) async {
    if (nameBookController.text.isEmpty) {
      getBooks();
      return;
    }

    if (isPagination) {
      if (isLoadingMore || !hasMoreData) return;
      isLoadingMore = true;
      emit(GetBooksPaginationLoading());
    } else {
      emit(GetBooksSearchLoading());
      allBooks.clear();
      page = 1;
      hasMoreData = true;
    }

    final result = await repo.getBookSearch(nameBookController.text, page);

    result.fold(
      (failure) {
        isLoadingMore = false;
        if (isPagination) {
          emit(GetBooksPaginationError(error: failure));
        } else {
          emit(GetBooksSearchError(error: failure));
        }
      },
      (data) {
        if (data.results != null && data.results!.isNotEmpty) {
          allBooks.addAll(data.results!);
          page++;
        } else {
          hasMoreData = false;
        }

        books = data;
        isLoadingMore = false;

        if (isPagination) {
          emit(GetBooksPaginationSuccess());
        } else {
          emit(GetBooksSearchSuccess());
        }
      },
    );
  }

  void onSearchSubmitted(String value) {
    nameBookController.text = value.trim();
    isSearching = nameBookController.text.isNotEmpty;
    searchBooks();
  }
}
