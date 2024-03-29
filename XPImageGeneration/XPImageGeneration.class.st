Class {
	#name : #XPImageGeneration,
	#superclass : #Object,
	#category : #'XPImageGeneration-Core'
}

{ #category : #actions }
XPImageGeneration class >> fixRichTextComposerErrorForClassNamed: className [

	| methodSource theClass |
	self flag: 'Hacky. Should be changed in the future'.
	theClass := self getClassNamed: className.
	methodSource := (theClass >> #asRenderedText) sourceCode.
	methodSource := methodSource
		                copyReplaceAll: 'PRRichTextComposer'
		                with: 'MicRichTextComposer'.
	theClass compile: methodSource
]

{ #category : #actions }
XPImageGeneration class >> fixRichTextComposerErrors [

	self fixRichTextComposerErrorForClassNamed: #ClyRichTextClassCommentEditorToolMorph.
	self fixRichTextComposerErrorForClassNamed: #ClyPackageRichTextCommentEditorToolMorph.
]

{ #category : #actions }
XPImageGeneration class >> generateImage [

	EpMonitor disableDuring: [ 
		self loadBaselines.
		self loadExperimentsPackage.
		self install ]
]

{ #category : #'as yet unclassified' }
XPImageGeneration class >> getClassNamed: aString [

	^ self environment at: aString
]

{ #category : #actions }
XPImageGeneration class >> install [

	"Executed after the baseline. Fixes some bugs"

	self fixRichTextComposerErrors
]

{ #category : #'as yet unclassified' }
XPImageGeneration class >> loadBaselines [

	"Silent-ish loading"

	"Phex should always point to the Pharo-XP-Tools Phex repository. Don't change this unless you have your own modified Phex"

	Metacello new
		baseline: 'Phex';
		repository: 'github://Pharo-XP-Tools/Phex:main';
		onWarning: [ :ex | ex resume ];
		load
]

{ #category : #'as yet unclassified' }
XPImageGeneration class >> loadExperimentsPackage [

	"Loads the unloaded package Experiments"

	"Why not including it in the baseline? 
Experiments package depends on Phex.
The image generation baseline internally executes the other baselines. So, dependencies are hidden from this baseline. By including the Experiments package in the baseline, Iceberg will try to load the Experiment package before executing the baselines (which produces a dependency error). A possible (untested) solution would be to put the baseline execution as a preload action, however, this class (XPImageGeneration) would not be loaded yet. "

	(IceRepository repositories select: [ :r | 
		 r name = 'XPImageGeneration' ]) first workingCopy 
		loadPackageNamed: #Experiments
]
