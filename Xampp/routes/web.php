<?php

use App\Http\Controllers\TravelMateContentController;
use App\Http\Controllers\TravelMateTransportController;
use App\Http\Controllers\TravelMateDiscoveryController;
use App\Http\Controllers\TravelMateOperationsController;
use App\Http\Controllers\TravelMateSecurityController;
use App\Http\Controllers\TravelMateDemoController;
use App\Http\Controllers\TravelMateHomeController;
use App\Http\Controllers\TravelMateAuthController;
use App\Http\Middleware\EnsureTravelMateAccountActive;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\TravelMateBrowseController;
use App\Http\Controllers\TravelMateWishlistController;
use App\Http\Controllers\TravelMateTripController;

use App\Http\Controllers\TravelMateOwnerController;
use App\Http\Controllers\TravelMateBookingController;
use App\Http\Controllers\TravelMateInventoryController;
use App\Http\Controllers\TravelMateAccountController;
use App\Http\Controllers\TravelMatePlacesController;
use App\Http\Controllers\TravelMateAdminController;
use App\Http\Controllers\TravelMateReviewController;
use App\Http\Middleware\RequireTravelMateRole;

Route::get('/reviews/{kind}/{slug}', [TravelMateReviewController::class, 'index'])
    ->whereIn('kind', ['destination','listing'])->name('reviews.index');

Route::get('/directory', [TravelMatePlacesController::class, 'directory'])->name('directory.index');
Route::get('/', [TravelMateHomeController::class,'index'])->name('home');
Route::get('/destinations', [TravelMateBrowseController::class, 'index'])->name('destinations.index');
Route::get('/destinations/{slug}', [TravelMateBrowseController::class, 'destination'])->name('destinations.show');
Route::get('/listings/{slug}', [TravelMateBrowseController::class, 'listing'])->name('listings.show');

Route::middleware('guest')->group(function () {
    Route::get('/register', [TravelMateAuthController::class, 'registerForm'])->name('register');
    Route::post('/register', [TravelMateAuthController::class, 'register'])
        ->middleware('throttle:5,1')->name('register.store');
    Route::get('/login', [TravelMateAuthController::class, 'loginForm'])->name('login');
    Route::post('/login', [TravelMateAuthController::class, 'login'])
        ->middleware('throttle:20,1')->name('login.store');
});

Route::middleware(['auth', EnsureTravelMateAccountActive::class])->group(function () {
    Route::get('/wishlist', [TravelMateWishlistController::class, 'index'])->name('wishlist.index');
    Route::post('/wishlist/{destination}', [TravelMateWishlistController::class, 'store'])
        ->whereNumber('destination')->middleware('throttle:60,1')->name('wishlist.store');
    Route::delete('/wishlist/{destination}', [TravelMateWishlistController::class, 'destroy'])
        ->whereNumber('destination')->middleware('throttle:60,1')->name('wishlist.destroy');
    Route::get('/trips', [TravelMateTripController::class, 'index'])->name('trips.index');
    Route::post('/trips', [TravelMateTripController::class, 'store'])->middleware('throttle:30,1')->name('trips.store');
    Route::get('/trips/{trip}', [TravelMateTripController::class, 'show'])->whereNumber('trip')->name('trips.show');
    Route::patch('/trips/{trip}', [TravelMateTripController::class, 'update'])->whereNumber('trip')->name('trips.update');
    Route::post('/trips/{trip}/items', [TravelMateTripController::class, 'storeItem'])->whereNumber('trip')
        ->middleware('throttle:60,1')->name('trips.items.store');
    Route::get('/trips/{trip}/items/{item}/edit', [TravelMateTripController::class, 'editItem'])
        ->whereNumber('trip')->whereNumber('item')->name('trips.items.edit');
    Route::patch('/trips/{trip}/items/{item}', [TravelMateTripController::class, 'updateItem'])
        ->whereNumber('trip')->whereNumber('item')->name('trips.items.update');
    Route::delete('/trips/{trip}/items/{item}', [TravelMateTripController::class, 'destroyItem'])
        ->whereNumber('trip')->whereNumber('item')->name('trips.items.destroy');
    Route::post('/reviews/{kind}/{slug}', [TravelMateReviewController::class, 'store'])
        ->whereIn('kind', ['destination','listing'])->middleware('throttle:20,1')->name('reviews.store');
    Route::middleware(RequireTravelMateRole::class.':business_owner')->group(function () {
        Route::get('/owner', [TravelMateOwnerController::class, 'index'])->name('owner.index');
        Route::post('/owner/listings', [TravelMateOwnerController::class, 'store'])->middleware('throttle:20,1')->name('owner.store');
        Route::get('/owner/listings/{listing}', [TravelMateOwnerController::class, 'edit'])->whereNumber('listing')->name('owner.edit');
        Route::patch('/owner/listings/{listing}', [TravelMateOwnerController::class, 'update'])->whereNumber('listing')->name('owner.update');
        Route::post('/owner/listings/{listing}/deactivate', [TravelMateOwnerController::class, 'deactivate'])->whereNumber('listing')->name('owner.deactivate');
    });
    Route::middleware(RequireTravelMateRole::class.':admin')->group(function () {
        Route::get('/admin/destinations', [TravelMatePlacesController::class, 'index'])->name('admin.places');
        Route::get('/admin/destinations/create', [TravelMatePlacesController::class, 'create'])->name('admin.places.create');
        Route::post('/admin/destinations', [TravelMatePlacesController::class, 'store'])->name('admin.places.store');
        Route::get('/admin/destinations/{destination}/edit', [TravelMatePlacesController::class, 'edit'])->whereNumber('destination')->name('admin.places.edit');
        Route::patch('/admin/destinations/{destination}', [TravelMatePlacesController::class, 'update'])->whereNumber('destination')->name('admin.places.update');
        Route::get('/admin/categories', [TravelMatePlacesController::class, 'categories'])->name('admin.categories');
        Route::post('/admin/categories', [TravelMatePlacesController::class, 'storeCategory'])->name('admin.categories.store');
        Route::get('/admin/categories/{category}/edit', [TravelMatePlacesController::class, 'editCategory'])->whereNumber('category')->name('admin.categories.edit');
        Route::patch('/admin/categories/{category}', [TravelMatePlacesController::class, 'updateCategory'])->whereNumber('category')->name('admin.categories.update');
        Route::get('/admin', [TravelMateAdminController::class, 'index'])->name('admin.index');
        Route::get('/admin/listings/{listing}', [TravelMateAdminController::class, 'show'])->whereNumber('listing')->name('admin.show');
        Route::post('/admin/listings/{listing}/decision', [TravelMateAdminController::class, 'decide'])->whereNumber('listing')->name('admin.decide');
        Route::get('/admin/reviews', [TravelMateAdminController::class, 'reviews'])->name('admin.reviews');
        Route::patch('/admin/reviews/{review}', [TravelMateAdminController::class, 'moderateReview'])->whereNumber('review')->name('admin.reviews.update');
    });
    Route::get('/bookings', [TravelMateBookingController::class, 'index'])->name('bookings.index');
    Route::get('/reserve/{listing}', [TravelMateBookingController::class, 'create'])->whereNumber('listing')->name('bookings.create');
    Route::post('/reserve/{listing}', [TravelMateBookingController::class, 'store'])->whereNumber('listing')->middleware('throttle:20,1')->name('bookings.store');
    Route::get('/bookings/{booking}', [TravelMateBookingController::class, 'show'])->whereNumber('booking')->name('bookings.show');
    Route::post('/bookings/{booking}/cancel', [TravelMateBookingController::class, 'cancel'])->whereNumber('booking')->name('bookings.cancel');
    Route::middleware(RequireTravelMateRole::class.':business_owner')->group(function () {
        Route::get('/owner-reservations', [TravelMateBookingController::class, 'ownerIndex'])->name('owner.bookings');
        Route::get('/owner-reservations/{booking}', [TravelMateBookingController::class, 'ownerShow'])->whereNumber('booking')->name('owner.bookings.show');
        Route::post('/owner-reservations/{booking}/decision', [TravelMateBookingController::class, 'decide'])->whereNumber('booking')->name('owner.bookings.decide');
        Route::get('/owner-inventory/{listing}', [TravelMateInventoryController::class, 'index'])->whereNumber('listing')->name('owner.inventory');
        Route::post('/owner-inventory/{listing}', [TravelMateInventoryController::class, 'store'])->whereNumber('listing')->middleware('throttle:30,1')->name('owner.inventory.store');
        Route::get('/owner-inventory/{listing}/{inventory}', [TravelMateInventoryController::class, 'edit'])->whereNumber('listing')->whereNumber('inventory')->name('owner.inventory.edit');
        Route::patch('/owner-inventory/{listing}/{inventory}', [TravelMateInventoryController::class, 'update'])->whereNumber('listing')->whereNumber('inventory')->name('owner.inventory.update');
    });
    Route::get('/profile', [TravelMateAccountController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [TravelMateAccountController::class, 'update'])->middleware('throttle:30,1')->name('profile.update');
    Route::get('/notifications', [TravelMateAccountController::class, 'notifications'])->name('notifications.index');
    Route::post('/notifications/read-all', [TravelMateAccountController::class, 'readAll'])->name('notifications.readAll');
    Route::post('/notifications/{notification}/read', [TravelMateAccountController::class, 'read'])->whereNumber('notification')->name('notifications.read');
    Route::get('/dashboard', [TravelMateAuthController::class, 'dashboard'])->name('dashboard');
});
Route::post('/logout', [TravelMateAuthController::class, 'logout'])->middleware('auth')->name('logout');

Route::get('/travelmate-photos/{photo}', [TravelMateContentController::class,'image'])->whereNumber('photo')->name('content.image');
Route::middleware(['auth', EnsureTravelMateAccountActive::class])->group(function(){
    Route::get('/manage-content/{kind}/{target}', [TravelMateContentController::class,'index'])->whereIn('kind',['listing','destination'])->whereNumber('target')->name('content.manage');
    Route::post('/manage-content/{kind}/{target}', [TravelMateContentController::class,'save'])->whereIn('kind',['listing','destination'])->whereNumber('target')->middleware('throttle:30,1')->name('content.save');
    Route::post('/manage-content/{kind}/{target}/photos', [TravelMateContentController::class,'upload'])->whereIn('kind',['listing','destination'])->whereNumber('target')->middleware('throttle:30,1')->name('content.upload');
    Route::post('/manage-content/{kind}/{target}/photos/{photo}', [TravelMateContentController::class,'photoAction'])->whereIn('kind',['listing','destination'])->whereNumber('target')->whereNumber('photo')->middleware('throttle:30,1')->name('content.photo');
    Route::get('/admin/photos',[TravelMateContentController::class,'queue'])->name('content.queue');
    Route::post('/manage-amenities',[TravelMateContentController::class,'amenity'])->middleware('throttle:30,1')->name('content.amenity');
});

Route::get('/transport',[TravelMateTransportController::class,'index'])->name('transport.index');
Route::get('/transport/{service}',[TravelMateTransportController::class,'show'])->whereNumber('service')->name('transport.show');
Route::middleware(['auth',EnsureTravelMateAccountActive::class])->group(function(){
    Route::get('/suggestions',[TravelMateDiscoveryController::class,'index'])->name('discovery.index');
    Route::middleware(RequireTravelMateRole::class.':business_owner')->group(function(){
        Route::get('/owner-transport',[TravelMateTransportController::class,'owner'])->name('transport.owner');
        Route::post('/owner-transport',[TravelMateTransportController::class,'storeProvider'])->middleware('throttle:30,1')->name('transport.owner.store');
        Route::get('/owner-transport/{provider}',[TravelMateTransportController::class,'editProvider'])->whereNumber('provider')->name('transport.owner.edit');
        Route::patch('/owner-transport/{provider}',[TravelMateTransportController::class,'updateProvider'])->whereNumber('provider')->middleware('throttle:30,1')->name('transport.owner.update');
        Route::post('/owner-transport/{provider}/services',[TravelMateTransportController::class,'storeService'])->whereNumber('provider')->middleware('throttle:30,1')->name('transport.services.store');
        Route::get('/owner-transport/{provider}/services/{service}/edit',[TravelMateTransportController::class,'editService'])->whereNumber('provider')->whereNumber('service')->name('transport.services.edit');
        Route::patch('/owner-transport/{provider}/services/{service}',[TravelMateTransportController::class,'updateService'])->whereNumber('provider')->whereNumber('service')->middleware('throttle:30,1')->name('transport.services.update');
        Route::post('/owner-transport/{provider}/services/{service}/deactivate',[TravelMateTransportController::class,'deactivate'])->whereNumber('provider')->whereNumber('service')->middleware('throttle:30,1')->name('transport.services.deactivate');
    });
    Route::middleware(RequireTravelMateRole::class.':admin')->group(function(){
        Route::get('/admin/transport',[TravelMateTransportController::class,'admin'])->name('transport.admin');
        Route::get('/admin/transport/{service}',[TravelMateTransportController::class,'review'])->whereNumber('service')->name('transport.review');
        Route::post('/admin/transport/{service}',[TravelMateTransportController::class,'decide'])->whereNumber('service')->name('transport.decide');
        Route::get('/admin/preferences',[TravelMateDiscoveryController::class,'preferences'])->name('discovery.preferences');
        Route::post('/admin/preferences',[TravelMateDiscoveryController::class,'addPreference'])->middleware('throttle:30,1')->name('discovery.preferences.store');
    });
});

Route::middleware(['auth',EnsureTravelMateAccountActive::class])->group(function(){
    Route::get('/issues',[TravelMateOperationsController::class,'issues'])->name('issues.index');
    Route::get('/issues/create',[TravelMateOperationsController::class,'create'])->name('issues.create');
    Route::post('/issues',[TravelMateOperationsController::class,'store'])->middleware('throttle:5,1')->name('issues.store');
    Route::get('/issues/{issue}',[TravelMateOperationsController::class,'show'])->whereNumber('issue')->name('issues.show');
    Route::middleware(RequireTravelMateRole::class.':admin')->group(function(){
        Route::get('/admin/accounts',[TravelMateOperationsController::class,'accounts'])->name('operations.accounts');
        Route::patch('/admin/accounts/{account}',[TravelMateOperationsController::class,'account'])->whereNumber('account')->middleware('throttle:10,1')->name('operations.account');
        Route::get('/admin/issues',[TravelMateOperationsController::class,'adminIssues'])->name('operations.issues');
        Route::get('/admin/issues/{issue}',[TravelMateOperationsController::class,'adminIssue'])->whereNumber('issue')->name('operations.issue');
        Route::patch('/admin/issues/{issue}',[TravelMateOperationsController::class,'moderate'])->whereNumber('issue')->middleware('throttle:10,1')->name('operations.moderate');
        Route::get('/admin/analytics',[TravelMateOperationsController::class,'analytics'])->name('operations.analytics');
        Route::post('/admin/analytics',[TravelMateOperationsController::class,'generate'])->middleware('throttle:10,1')->name('operations.generate');
        Route::get('/admin/analytics/{report}',[TravelMateOperationsController::class,'report'])->whereNumber('report')->name('operations.report');
        Route::get('/admin/analytics/{report}/csv',[TravelMateOperationsController::class,'csv'])->whereNumber('report')->name('operations.csv');
    });
});

Route::middleware('guest')->group(function(){
Route::get('/forgot-password',[TravelMateSecurityController::class,'forgot'])->name('security.forgot');
Route::post('/forgot-password',[TravelMateSecurityController::class,'send'])->middleware('throttle:5,1')->name('security.send');
Route::get('/reset-password/{token}',[TravelMateSecurityController::class,'resetForm'])->name('security.reset.form');
Route::post('/reset-password',[TravelMateSecurityController::class,'reset'])->middleware('throttle:5,1')->name('security.reset');
});
Route::middleware(['auth',EnsureTravelMateAccountActive::class])->group(function(){
Route::get('/change-password',[TravelMateSecurityController::class,'edit'])->name('security.edit');
Route::post('/change-password',[TravelMateSecurityController::class,'change'])->middleware('throttle:5,1')->name('security.change');
Route::get('/demo-payments/{booking}',[TravelMateDemoController::class,'show'])->whereNumber('booking')->name('demo.show');
Route::post('/demo-payments/{booking}',[TravelMateDemoController::class,'pay'])->whereNumber('booking')->middleware('throttle:10,1')->name('demo.pay');
Route::post('/demo-payments/{booking}/refund',[TravelMateDemoController::class,'refund'])->whereNumber('booking')->middleware('throttle:10,1')->name('demo.refund');
Route::middleware(RequireTravelMateRole::class.':admin')->group(function(){
Route::get('/admin/demo-refunds',[TravelMateDemoController::class,'index'])->name('demo.admin');
Route::post('/admin/demo-refunds/{refund}',[TravelMateDemoController::class,'decide'])->whereNumber('refund')->middleware('throttle:10,1')->name('demo.decide');
});
});
